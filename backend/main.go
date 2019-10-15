package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"regexp"
)

type Product struct {
	Id           string  `json:"id"`
	Manufacturer string  `json:"manufacturer"`
	Model        string  `json:"model"`
	Price        float32 `json:"price"`
	Quantity     uint    `json:"qunatity"`
}

var sampleProducts = []Product{
	Product{"1", "Samsung", "Galaxy S7", 1999.0, 100},
	Product{"2", "Samsung", "Galaxy S8", 2299.0, 100},
	Product{"3", "Google", "Nexus 5", 1500.0, 20},
	Product{"4", "Google", "Nexus 6P", 1899.0, 20},
	Product{"5", "Google", "Pixel", 1999.0, 10},
	Product{"6", "Google", "Pixel 2", 2299.0, 20},
	Product{"7", "Google", "Pixel 3", 2599.0, 30},
}

var validPath = regexp.MustCompile("^/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)$")

func authorize(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var pathSegments = validPath.FindStringSubmatch(r.URL.Path)
		var id string
		if len(pathSegments) == 0 {
			id = ""
		} else if len(pathSegments) == 3 {
			id = pathSegments[2]
		} else {
			http.Error(w, "Invalid path", http.StatusBadRequest)
			return
		}
		fn(w, r, id)
	}
}

func productsHandler(w http.ResponseWriter, r *http.Request, id string) {
	switch r.Method {
	case "GET":
		if id == "" {
			getAllProducts(w)
		} else {
			getProduct(w, id)
		}
	case "POST":
		createProduct(w, r)
	case "DELETE":
		deleteProduct(w, id)
	case "PUT":
		updateProduct(w, r, id)
	default:
		http.Error(w, "Invalid method", http.StatusMethodNotAllowed)
	}
}

func createProduct(w http.ResponseWriter, r *http.Request) {
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

func updateProduct(w http.ResponseWriter, r *http.Request, id string) {
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

func getAllProducts(w http.ResponseWriter) {
	//TODO response json
	json.NewEncoder(w).Encode(sampleProducts)
}

func getProduct(w http.ResponseWriter, id string) {
	for _, product := range sampleProducts {
		if product.Id == id {
			json.NewEncoder(w).Encode(product)
		}
	}
}

func deleteProduct(w http.ResponseWriter, id string) {
	for i, product := range sampleProducts {
		if product.Id == id {
			sampleProducts = append(sampleProducts[:i], sampleProducts[i+1:]...)
			fmt.Fprint(w, "Successfully deleted product with id %s", id)
		}
	}
}
func deltaQuantity(w http.ResponseWriter, r *http.Request, id string) {
	//TODO
}

func main() {
	http.HandleFunc("/products/", authorize(productsHandler))
	http.HandleFunc("/deltaQuantity/", authorize(deltaQuantity))
	log.Fatal(http.ListenAndServe(":8080", nil))
}
