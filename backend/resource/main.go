package main

import (
	"encoding/json"
	"errors"
	"fmt"
	_ "github.com/dgrijalva/jwt-go"
	_ "github.com/joho/godotenv/autoload"
	"github.com/julienschmidt/httprouter"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"time"
)

type Product struct {
	Id           string `json:"id"`
	Manufacturer string `json:"manufacturer"`
	Model        string `json:"model"`
	Price        uint   `json:"price"`
	Quantity     uint   `json:"quantity"`
}

type wellknown struct {
	Issuer                            string   `json:"issuer"`
	AuthorizationEndpoint             string   `json:"authorization_endpoint"`
	TokenEndpoint                     string   `json:"token_endpoint"`
	UserinfoEndpoint                  string   `json:"userinfo_endpoint"`
	RevocationEndpoint                string   `json:"revocation_endpoint"`
	JwksURI                           string   `json:"jwks_uri"`
	ResponseTypesSupported            []string `json:"response_types_supported"`
	SubjectTypesSupported             []string `json:"subject_types_supported"`
	IDTokenSigningAlgValuesSupported  []string `json:"id_token_signing_alg_values_supported"`
	ScopesSupported                   []string `json:"scopes_supported"`
	TokenEndpointAuthMethodsSupported []string `json:"token_endpoint_auth_methods_supported"`
	ClaimsSupported                   []string `json:"claims_supported"`
}

type wellknownGoogle struct {
	wellknown
	CodeChallengeMethodsSupported []string `json:"code_challenge_methods_supported"`
}

type wellknownWarehouser struct {
	wellknown
	GrantTypesSupported                []string `json:"grant_types_supported"`
	ResponseModesSupported             []string `json:"response_modes_supported"`
	UserinfoSigningAlgValuesSupported  []string `json:"userinfo_signing_alg_values_supported"`
	RequestParameterSupported          bool     `json:"request_parameter_supported"`
	RequestURIParameterSupported       bool     `json:"request_uri_parameter_supported"`
	RequireRequestURIRegistration      bool     `json:"require_request_uri_registration"`
	ClaimsParameterSupported           bool     `json:"claims_parameter_supported"`
	BackchannelLogoutSupported         bool     `json:"backchannel_logout_supported"`
	BackchannelLogoutSessionSupported  bool     `json:"backchannel_logout_session_supported"`
	FrontchannelLogoutSupported        bool     `json:"frontchannel_logout_supported"`
	FrontchannelLogoutSessionSupported bool     `json:"frontchannel_logout_session_supported"`
	EndSessionEndpoint                 string   `json:"end_session_endpoint"`
}

var sampleProducts = []Product{
	Product{"1", "Samsung", "Galaxy S7", 1999, 100},
	Product{"2", "Samsung", "Galaxy S8", 2299, 100},
	Product{"3", "Google", "Nexus 5", 1500, 20},
	Product{"4", "Google", "Nexus 6P", 1899, 20},
	Product{"5", "Google", "Pixel", 1999, 10},
	Product{"6", "Google", "Pixel 2", 2299, 20},
	Product{"7", "Google", "Pixel 3", 2599, 30},
}

func main() {
	fbAppAccessToken := getFacebookAppAccessToken()
	googleWellknown := getWellknown("https://accounts.google.com")
	warehouserWellknown := getWellknown("https://home.stasbar.com:9000")
	googleJwks := getJwks(googleWellknown)
	warehouserJwks := getJwks(warehouserWellknown)

	router := httprouter.New()
	router.GET("/products", logger(getAllProducts))
	router.GET("/products/:id", logger(getProduct))
	router.POST("/products", logger(createProduct))
	router.DELETE("/products/:id", logger(deleteProduct))
	router.PATCH("/deltaQuantity/:id", logger(deltaQuantity))
	router.POST("/auth/google", logger(authGoogle(warehouserWellknown, googleJwks)))
	router.POST("/auth/warehouser", logger(authWarehouser(warehouserWellknown, warehouserJwks)))
	router.POST("/auth/facebook", logger(authFacebook(fbAppAccessToken)))
	sslCert := os.Getenv("STASBAR_SSL_CERT")
	sslKey := os.Getenv("STASBAR_SSL_KEY")
	httpsPort := os.Getenv("PORT_HTTPS")
	log.Fatal(http.ListenAndServeTLS(":"+httpsPort, sslCert, sslKey, router))
}

func getFacebookAppAccessToken() string {
	clientId := os.Getenv("WAREHOURSER_CLIENT_ID")
	clientSecret := os.Getenv("WAREHOURSER_CLIENT_SECRET")
	url := "https://graph.facebook.com/oauth/access_token?client_id=" + clientId + "&client_secret=" + clientSecret + "&grant_type=client_credentials"
	jsonMap, err := getJsonMap(url)
	if err != nil {
		log.Fatal(err)
		return ""
	}
	return jsonMap["access_token"]
}

func authFacebook(fbAppAccessToken string) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		bodyJson, err := toJson(r.Body)
		if err != nil {
			log.Println(err)
		}
		accessToken := bodyJson["accessToken"]
		uri := "https://graph.facebook.com/debug_token?input_token=" + accessToken + "&access_token=" + fbAppAccessToken
		debugToken, err := getJsonMap(uri)
		if err != nil {
			log.Println(err)
		}
		log.Println(debugToken)
		// TODO test
	}
}

func authGoogle(warehouserWellknown *wellknown, warehouserJwks string) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.Fatal(err)
			return
		}
		params, err := url.ParseQuery(string(body))
		if err != nil {
			log.Fatal(err)
			return
		}
		fmt.Println("Query strings")
		for key, value := range params {
			fmt.Printf(" %s = %v\n", key, value)
		}

		jwtToken := params["tokenId"][0]
		url := "https://oauth2.googleapis.com/tokeninfo?id_token=" + jwtToken
		tokenInfo, err := getJsonMap(url)
		// TODO do it localy
		// https://developers.google.com/identity/protocols/OpenIDConnect#validatinganidtoken
		// 1. Verify signature based on googleCerts
		// jwt.Parse(jwtToken, googleCerts)
		if err != nil {
			log.Println("Failed to prase google tokenInfo")
			log.Println(err.Error())
		}
		formattedJson, err := json.MarshalIndent(tokenInfo, "", "  ")
		if err != nil {
			log.Println(err)
		}
		log.Println(string(formattedJson))

		err = verifyGoogleToken(tokenInfo)
		if err != nil {
			fmt.Fprint(w, err)
		}

		// TODO exchange code for access token and ID Token.
	}
}
func authWarehouser(wellknown *wellknown, warehouserJwks string) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.Fatal(err)
			return
		}
		params, err := url.ParseQuery(string(body))
		if err != nil {
			log.Fatal(err)
			return
		}
		fmt.Println("Query strings")
		for key, value := range params {
			fmt.Printf(" %s = %v\n", key, value)
		}

		jwtToken := params["tokenId"][0]
		url := wellknown.UserinfoEndpoint
		tokenInfo, err := getJsonMapAuthenticated(url, jwtToken)
		// TODO do it localy
		// https://developers.google.com/identity/protocols/OpenIDConnect#validatinganidtoken
		// 1. Verify signature based on googleCerts
		// jwt.Parse(jwtToken, googleCerts)
		if err != nil {
			log.Println(err)
		}
		formattedJson, err := json.MarshalIndent(tokenInfo, "", "  ")
		if err != nil {
			log.Println(err)
		}
		log.Println(string(formattedJson))

		err = verifyWarehouserToken(tokenInfo, wellknown)
		if err != nil {
			fmt.Fprint(w, err)
			log.Fatal(err)
		}

		// TODO exchange code for access token and ID Token.
	}
}

func verifyWarehouserToken(tokenMap map[string]string, wellknown *wellknown) error {
	iss, ok := tokenMap["iss"]
	if !ok {
		log.Println("could not find iss field in id_token")
	}
	if iss != wellknown.Issuer {
		log.Printf("Invalid iss %s\n", iss)
	}

	expStr, ok := tokenMap["exp"]
	if !ok {
		return errors.New("could not find exp field in id_token")
	}

	exp, err := strconv.ParseInt(expStr, 10, 64)
	if err != nil {
		return errors.New("exp is not int")
	}
	if exp < time.Now().Unix() {
		return errors.New("token expired")
	}
	// 2. check if iss is https://accounts.google.com or accounts.google.com
	// 3. ckeck of aud is app client id
	// 4. exp is not past
	return nil
}

func verifyGoogleToken(tokenMap map[string]string) error {
	iss, ok := tokenMap["iss"]
	if !ok {
		log.Println("could not find iss field in id_token")
	}
	if iss != "https://accounts.google.com" && iss != "accounts.google.com" {
		log.Printf("Invalid iss %s\n", iss)
	}

	expStr, ok := tokenMap["exp"]
	if !ok {
		return errors.New("could not find exp field in id_token")
	}

	exp, err := strconv.ParseInt(expStr, 10, 64)
	if err != nil {
		return errors.New("exp is not int")
	}
	if exp < time.Now().Unix() {
		return errors.New("token expired")
	}
	// 2. check if iss is https://accounts.google.com or accounts.google.com
	// 3. ckeck of aud is app client id
	// 4. exp is not past
	return nil
}

func getWellknown(publicUrl string) *wellknown {
	wellknownObj := new(wellknown)
	err := getJson(fmt.Sprintf("%s/.well-known/openid-configuration", publicUrl), wellknownObj)
	if err != err {
		log.Fatal(err)
		return nil
	}
	return wellknownObj
}

func getJwks(wellknown *wellknown) string {
	jwks, err := getString(wellknown.JwksURI)
	if err != nil {
		log.Println("Failed to parse jwks")
		log.Fatal(err)
		return ""
	}
	return jwks
}

func toJson(r io.ReadCloser) (map[string]string, error) {
	body, readErr := ioutil.ReadAll(r)
	if readErr != nil {
		log.Println(readErr)
		return nil, readErr
	}
	jsonMap := map[string]string{}
	jsonErr := json.Unmarshal(body, &jsonMap)
	if jsonErr != nil {
		return nil, jsonErr
	}
	return jsonMap, nil
}

func getJsonMap(url string) (map[string]string, error) {
	jsonMap := map[string]string{}
	return jsonMap, getJson(url, &jsonMap)
}

func getString(url string) (string, error) {
	client := http.Client{
		Timeout: time.Second * 2,
	}
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Println(err)
		return "", err
	}
	req.Header.Set("User-Agent", "warehouser-resource")

	log.Println(url)
	res, getErr := client.Do(req)
	if getErr != nil {
		log.Println(getErr)
		return "", getErr
	}

	body, readErr := ioutil.ReadAll(res.Body)
	return string(body), readErr
}

func getJson(url string, outObj interface{}) error {
	client := http.Client{
		Timeout: time.Second * 2,
	}
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Println(err)
		return err
	}
	req.Header.Set("User-Agent", "warehouser-resource")

	log.Println(url)
	res, getErr := client.Do(req)
	if getErr != nil {
		log.Println(getErr)
		return getErr
	}

	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Println(readErr)
		return readErr
	}
	log.Println(string(body))
	jsonErr := json.Unmarshal(body, outObj)
	if jsonErr != nil {
		return jsonErr
	}
	return nil
}

func getJsonMapAuthenticated(url string, bearerToken string) (map[string]string, error) {
	jsonMap := map[string]string{}
	return jsonMap, getJsonAuthenticated(url, &jsonMap, bearerToken)
}

func getJsonAuthenticated(url string, outObj interface{}, bearerToken string) error {
	client := http.Client{
		Timeout: time.Second * 2,
	}
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Println(err)
		return err
	}
	req.Header.Set("User-Agent", "warehouser-resource")
	req.Header.Set("Authentication", fmt.Sprintf("Bearer %s", bearerToken))

	log.Println(url)
	res, getErr := client.Do(req)
	if getErr != nil {
		log.Println(getErr)
		return getErr
	}

	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Println(readErr)
		return readErr
	}
	jsonErr := json.Unmarshal(body, outObj)
	if jsonErr != nil {
		return jsonErr
	}
	return nil
}

func logger(next httprouter.Handle) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		fmt.Println(r.RequestURI)
		next(w, r, ps)
	}
}

func getAllProducts(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	//TODO response json
	json.NewEncoder(w).Encode(sampleProducts)
}

func getProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	id := ps.ByName("id")
	for _, product := range sampleProducts {
		if product.Id == id {
			json.NewEncoder(w).Encode(product)
		}
	}
}

func createProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	var newProduct Product
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Request body empty", http.StatusBadRequest)
		return
	}

	json.Unmarshal(reqBody, &newProduct)

	newProduct.Quantity = 0 // Requiremenet

	sampleProducts = append(sampleProducts, newProduct)
	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(newProduct)
}

func updateProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	id := ps.ByName("id")
	var updatedProduct Product

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Request body empty", http.StatusBadRequest)
		return
	}
	json.Unmarshal(reqBody, &updatedProduct)
	//TODO validate data

	for i, product := range sampleProducts {
		if product.Id == id {
			product.Manufacturer = updatedProduct.Manufacturer
			product.Model = updatedProduct.Model
			product.Price = updatedProduct.Price
			product.Quantity = updatedProduct.Quantity
			sampleProducts = append(sampleProducts[:i], product)
			json.NewEncoder(w).Encode(product)
			return
		}
	}
}

func deleteProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	id := ps.ByName("id")
	for i, product := range sampleProducts {
		if product.Id == id {
			sampleProducts = append(sampleProducts[:i], sampleProducts[i+1:]...)
			fmt.Fprintf(w, "Successfully deleted product with id %s", id)
		}
	}
}
func deltaQuantity(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	//TODO
}
