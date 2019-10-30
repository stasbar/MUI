package main

import (
	"encoding/json"
  "encoding/base64"
	"fmt"
	_ "github.com/joho/godotenv/autoload"
	"github.com/julienschmidt/httprouter"
	"io/ioutil"
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

  decoded, err := base64.StdEncoding.DecodeString(params["tokenId"][0])
  if err != nil {
    fmt.Fprint(w, "Error", err)
  }
  fmt.Fprint(w, decoded)
  // TODO exchange code for access token and ID Token. 
}

func authFacebook(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {

}

func logger(next httprouter.Handle) httprouter.Handle {
  return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
    fmt.Println(r.RequestURI)
    next(w,r,ps)
  }
}

func main() {
	router := httprouter.New()
	router.GET("/products", logger(getAllProducts))
	router.GET("/products/:id", logger(getProduct))
	router.POST("/products", logger(createProduct))
	router.DELETE("/products/:id", logger(deleteProduct))
	router.PATCH("/deltaQuantity/:id", logger(deltaQuantity))
  router.POST("/auth/google", logger(authGoogle))
  router.POST("/auth/facebook", logger(authFacebook))
	sslCert := os.Getenv("STASBAR_SSL_CERT")
	sslKey := os.Getenv("STASBAR_SSL_KEY")
	httpsPort := os.Getenv("HTTPS_PORT")
	log.Fatal(http.ListenAndServeTLS(":"+httpsPort, sslCert, sslKey, router))
}
