package main

import (
	"encoding/json"
	"fmt"
	_ "github.com/dgrijalva/jwt-go"
	_ "github.com/joho/godotenv/autoload"
	"github.com/julienschmidt/httprouter"
	"github.com/satori/go.uuid"
	"io"
	"io/ioutil"
	"log"
	"net/http"
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

type TokenIntrospection struct {
	Active    bool   `json:"active"`
	Scope     string `json:"scope"`
	ClientID  string `json:"client_id"`
	Sub       string `json:"sub"`
	Exp       int    `json:"exp"`
	Iat       int    `json:"iat"`
	Iss       string `json:"iss"`
	TokenType string `json:"token_type"`
	Ext       struct {
		Role string `json:"role"`
	} `json:"ext"`
}

func uuidv4() string {
	return uuid.Must(uuid.NewV4()).String()
}

var sampleProducts = []Product{
	Product{uuidv4(), "Samsung", "Galaxy S7", 1999, 100},
	Product{uuidv4(), "Samsung", "Galaxy S8", 2299, 100},
	Product{uuidv4(), "Google", "Nexus 5", 1500, 20},
	Product{uuidv4(), "Google", "Nexus 6P", 1899, 20},
	Product{uuidv4(), "Google", "Pixel", 1999, 10},
	Product{uuidv4(), "Google", "Pixel 2", 2299, 20},
	Product{uuidv4(), "Google", "Pixel 3", 2599, 30},
}

func main() {
	router := httprouter.New()
	router.GET("/products", logger(getAllProducts))
	router.GET("/products/:id", logger(getProduct))
	router.POST("/products", logger(createProduct))
	router.PUT("/products/:id", logger(updateProduct))
	router.DELETE("/products/:id", logger(deleteProduct))
	router.PATCH("/deltaQuantity/:id", logger(deltaQuantity))
	router.GET("/currentUser", logger(currentUser))
	log.Fatal(http.ListenAndServe(":80", router))
}

func currentUser(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	if user, err := json.Marshal(map[string]string{
		"email": r.Header.Get("X-Email"),
		"role":  r.Header.Get("X-Role"),
	}); err != nil {
		log.Println(err)
		fmt.Fprint(w, err)
	} else {
		log.Printf("user: %s", string(user))
		fmt.Fprint(w, string(user))
	}
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

	req.Header = map[string][]string{
		"Accept":        []string{"application/json"},
		"Authorization": []string{fmt.Sprintf("Bearer %s", bearerToken)},
		"User-Agent":    []string{"warehouser-resource"},
	}

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
	json.NewEncoder(w).Encode(sampleProducts)
}

func getProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	id := ps.ByName("id")
	for _, product := range sampleProducts {
		if product.Id == id {
			json.NewEncoder(w).Encode(product)
			return
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
	newProduct.Id = uuidv4()

	sampleProducts = append(sampleProducts, newProduct)
	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(newProduct)
}

func updateProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	id := ps.ByName("id")

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Request body empty", http.StatusBadRequest)
		return
	}
	var updatedProduct Product
	err = json.Unmarshal(reqBody, &updatedProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		log.Println(err)
	}

	for i, product := range sampleProducts {
		if product.Id == id {
			log.Printf("Found product %v\n", product)

			if updatedProduct.Manufacturer != "" {
				sampleProducts[i].Manufacturer = updatedProduct.Manufacturer
			}
			if updatedProduct.Model != "" {
				sampleProducts[i].Model = updatedProduct.Model
			}
			if updatedProduct.Price != 0 {
				sampleProducts[i].Price = updatedProduct.Price
			}
			if updatedProduct.Quantity != 0 {
				sampleProducts[i].Quantity = updatedProduct.Quantity
			}
			json.NewEncoder(w).Encode(sampleProducts[i])
			log.Println(sampleProducts[i])
			return
		}
	}
}

func deleteProduct(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	role := r.Header.Get("X-Role")
	if role != "manager" {
		http.Error(w, "Only manager can delete products", http.StatusForbidden)
		log.Println("Only manager can delete products")
		return
	}

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
