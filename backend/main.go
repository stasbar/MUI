package main

import (
	"encoding/json"
  "time"
	"fmt"
	_ "github.com/joho/godotenv/autoload"
	"github.com/julienschmidt/httprouter"
 _ "github.com/dgrijalva/jwt-go"
	"io/ioutil"
  "io"
	"log"
	"net/http"
	"net/url"
	"os"
)

type Product struct {
	Id           string `json:"id"`
	Manufacturer string `json:"manufacturer"`
	Model        string `json:"model"`
	Price        uint   `json:"price"`
	Quantity     uint   `json:"quantity"`
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
			fmt.Fprint(w, "Successfully deleted product with id %s", id)
		}
	}
}
func deltaQuantity(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	//TODO
}

func authFacebook(fbAppAccessToken string) httprouter.Handle{
  return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
    bodyJson, err := toJson(r.Body)
    if err != nil {
      log.Println(err)
    }
    accessToken := bodyJson["accessToken"]
    uri := "https://graph.facebook.com/debug_token?input_token="+accessToken+"&access_token="+fbAppAccessToken
    debugToken,err :=  getJsonMap(uri)
    if err != nil {
      log.Println(err)
    }
    log.Println(debugToken)
    // TODO test
  }
}

func authGoogle(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
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
  url := "https://oauth2.googleapis.com/tokeninfo?id_token="+jwtToken
  getJsonMap(url)
  // TODO 
  // debug with 

  // 1. Verify signature based on getGoogleJwtClaims()
  // jwt.Parse(jwtToken, )
  // 2. check if iss is https://accounts.google.com or accounts.google.com
  // 3. ckeck of aud is app client id
  // 4. exp is not past
  // get userinfo_endpoint from discovery
  // https://accounts.google.com/.well-known/openid-configuration



  // TODO exchange code for access token and ID Token. 
}

func getGoogleJwtClaims() {
  // get JSON from https://accounts.google.com/.well-known/openid-configuration
  jsonMap, err := getJsonMap("https://accounts.google.com/.well-known/openid-configuration")
  if err != err {
    log.Fatal(err)
    return
  }
  log.Println(jsonMap)
  log.Println(jsonMap["jwks_uri"])
}

func getFacebookAppAccessToken() (string, error){
	clientId := os.Getenv("WAREHOURSER_CLIENT_ID")
	clientSecret := os.Getenv("WAREHOURSER_CLIENT_SECRET")
  jsonMap, err := getJsonMap("https://graph.facebook.com/oauth/access_token?client_id="+clientId+"&client_secret="+clientSecret+"&grant_type=client_credentials")
  if err != nil {
    log.Fatal(err)
    return "", err
  }
  return jsonMap["access_token"], nil
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
    next(w,r,ps)
  }
}

func main() {
  fbAppAccessToken, err := getFacebookAppAccessToken()
  if err != nil {
    log.Fatal(err)
  }
	router := httprouter.New()
	router.GET("/products", logger(getAllProducts))
	router.GET("/products/:id", logger(getProduct))
	router.POST("/products", logger(createProduct))
	router.DELETE("/products/:id", logger(deleteProduct))
	router.PATCH("/deltaQuantity/:id", logger(deltaQuantity))
  router.POST("/auth/google", logger(authGoogle))
  router.POST("/auth/facebook", logger(authFacebook(fbAppAccessToken)))
	sslCert := os.Getenv("STASBAR_SSL_CERT")
	sslKey := os.Getenv("STASBAR_SSL_KEY")
	httpsPort := os.Getenv("HTTPS_PORT")
	log.Fatal(http.ListenAndServeTLS(":"+httpsPort, sslCert, sslKey, router))
}
