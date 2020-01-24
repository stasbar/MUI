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
	Id               string `json:"id"`
	Manufacturer     string `json:"manufacturer"`
	Model            string `json:"model"`
	Price            uint   `json:"price"`
	Quantity         int    `json:"quantity"`
	LastTimeModified uint   `json:"lastTimeModified"`
	Width            uint   `json:"width"`
	Height           uint   `json:"height"`
	Length           uint   `json:"length"`
	Deleted          bool   `json:"deleted"`
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

var sampleProducts = map[string]*Product{
	"123asd": &Product{"123asd", "Samsung", "Galaxy S7", 1999, 100, 0, 1000, 5000, 100, false},
	"234sdf": &Product{"234sdf", "Samsung", "Galaxy S8", 2299, 100, 0, 2000, 4000, 200, false},
	"345dfg": &Product{"345dfg", "Google", "Nexus 5", 1500, 20, 0, 3000, 3000, 300, false},
	"456fgh": &Product{"456fgh", "Google", "Nexus 6P", 1899, 20, 0, 4000, 2000, 400, false},
	"567ghj": &Product{"567ghj", "Google", "Pixel", 1999, 10, 0, 5000, 1000, 500, false},
}

var warehouseProductDeviceSubtotal = map[string]map[string]map[string]int{
	"lema19": productDeviceSubtotal,
	"jaskowaDolina60": map[string]map[string]int{
		"123asd": map[string]int{
			"123": 1,
			"234": -1,
		},
		"234sdf": map[string]int{
			"123": 5,
			"234": -5,
		},
		"345dfg": map[string]int{
			"123": 6,
			"234": -6,
		},
		"456fgh": map[string]int{
			"123": 7,
			"234": -7,
		},
		"567ghj": map[string]int{
			"123": 8,
			"234": -8,
		},
	},
}

// initial subtotals
var productDeviceSubtotal = map[string]map[string]int{
	"123asd": map[string]int{
		"123": 10,
		"234": -5,
	},
	"234sdf": map[string]int{
		"123": -20,
		"234": 30,
	},
	"345dfg": map[string]int{
		"123": -20,
		"234": 30,
	},
	"456fgh": map[string]int{
		"123": -20,
		"234": 30,
	},
	"567ghj": map[string]int{
		"123": -20,
		"234": 30,
	},
}

func main() {
	router := httprouter.New()
	router.GET("/products", logger(getAllProducts))
	router.GET("/warehouses", logger(getAllWarehouses))
	router.GET("/products/:id", logger(getProduct))
	router.GET("/currentUser", logger(currentUser))
	router.POST("/sync", logger(sync))
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

func getAllWarehouses(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	keys := make([]string, len(warehouseProductDeviceSubtotal))

	i := 0
	for k := range warehouseProductDeviceSubtotal {
		keys[i] = k
		i++
	}

	json.NewEncoder(w).Encode(keys)
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

func sync(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	warehouses, ok := r.URL.Query()["warehouse"]
	var warehouse string
	if !ok || len(warehouses[0]) < 1 {
		warehouse = "lema19"
		log.Println("no warehouse specified, using lema19")
	} else {
		warehouse = warehouses[0]
	}
	deviceId := r.Header.Get("X-Device")
	log.Printf("sync with deviceId: %s", deviceId)

	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Request body empty", http.StatusBadRequest)
		return
	}

	var deviceState map[string]Product
	if err = json.Unmarshal(reqBody, &deviceState); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		log.Println(err)
		return
	}

	for i := range deviceState {
		product := deviceState[i]
		log.Printf("Product %v", product)

		if _, ok := sampleProducts[product.Id]; !ok {
			log.Printf("Add product %v \n", product)
			addProduct(product, deviceId, warehouse)
			continue
		}

		if _, ok := warehouseProductDeviceSubtotal[warehouse][product.Id]; !ok {
			warehouseProductDeviceSubtotal[warehouse][product.Id] = map[string]int{}
		}
		warehouseProductDeviceSubtotal[warehouse][product.Id][deviceId] = product.Quantity

		if product.LastTimeModified > sampleProducts[product.Id].LastTimeModified {
			log.Printf("Update product %v \n", product)
			if product.Deleted {
				log.Printf("Mark deleted product %v \n", product)
			}
			updateProduct(product, deviceId)
			continue
		}
	}
	sumupTotalQuantities(warehouse)
	respondWithUpdatedProducts(w)
}

func updateProduct(product Product, deviceId string) {
	sampleProducts[product.Id] = &product
}

func addProduct(product Product, deviceId string, warehouse string) {
	sampleProducts[product.Id] = &product

	warehouseProductDeviceSubtotal[warehouse][product.Id] = map[string]int{}
	warehouseProductDeviceSubtotal[warehouse][product.Id][deviceId] = product.Quantity

	sampleProducts[product.Id].Quantity = totalForProduct(product.Id, warehouse)
}

func sumupTotalQuantities(warehouse string) {
	for productId := range sampleProducts {
		sampleProducts[productId].Quantity = totalForProduct(productId, warehouse)
	}
}

func totalForProduct(productId string, warehouse string) int {
	total := 0
	for _, v := range warehouseProductDeviceSubtotal[warehouse][productId] {
		total += v
	}
	return total
}

func respondWithUpdatedProducts(w http.ResponseWriter) {
	log.Println("Responded with state")
	json.NewEncoder(w).Encode(sampleProducts)
}
