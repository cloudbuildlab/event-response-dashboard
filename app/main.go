package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"strconv"

	"event-response-app/internal/fastschema"
)

var (
	fsClient *fastschema.Client
	tpls    *template.Template
)

func main() {
	baseURL := os.Getenv("FASTSCHEMA_URL")
	if baseURL == "" {
		baseURL = "http://localhost:8000"
	}
	fsClient = fastschema.NewClient(baseURL, "event")

	var err error
	tpls, err = template.ParseGlob("web/templates/*.html")
	if err != nil {
		log.Fatalf("parse templates: %v", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", listHandler)
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/new", newFormHandler)
	mux.HandleFunc("/create", createHandler)
	mux.HandleFunc("/edit", editFormHandler)
	mux.HandleFunc("/update", updateHandler)
	mux.HandleFunc("/delete", deleteConfirmHandler)
	mux.HandleFunc("/delete/confirm", deleteHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on :%s (FASTSCHEMA_URL=%s)", port, baseURL)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "ok")
}

func listHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	events, err := fsClient.List()
	if err != nil {
		log.Printf("list: %v", err)
		http.Error(w, "Failed to list events", http.StatusInternalServerError)
		return
	}
	if events == nil {
		events = []fastschema.Event{}
	}
	createdID := r.URL.Query().Get("created")
	data := map[string]interface{}{"Events": events, "Created": createdID}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := tpls.ExecuteTemplate(w, "list.html", data); err != nil {
		log.Printf("template: %v", err)
		http.Error(w, "Internal error", http.StatusInternalServerError)
	}
}

func newFormHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := tpls.ExecuteTemplate(w, "form.html", map[string]interface{}{"Event": fastschema.Event{}, "Action": "/create", "Title": "New Event"}); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func createHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Bad form", http.StatusBadRequest)
		return
	}
	e := fastschema.Event{
		Title:       r.FormValue("title"),
		Description: r.FormValue("description"),
	}
	created, err := fsClient.Create(e)
	if err != nil {
		log.Printf("create: %v", err)
		http.Error(w, "Failed to create event", http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/?created="+strconv.Itoa(created.ID), http.StatusSeeOther)
	return
}

func editFormHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "id required", http.StatusBadRequest)
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil || id <= 0 {
		http.Error(w, "invalid id", http.StatusBadRequest)
		return
	}
	e, err := fsClient.Get(id)
	if err != nil {
		log.Printf("get: %v", err)
		http.Error(w, "Event not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := tpls.ExecuteTemplate(w, "form.html", map[string]interface{}{"Event": e, "Action": "/update", "Title": "Edit Event"}); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func updateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Bad form", http.StatusBadRequest)
		return
	}
	id, err := strconv.Atoi(r.FormValue("id"))
	if err != nil || id <= 0 {
		http.Error(w, "invalid id", http.StatusBadRequest)
		return
	}
	e := fastschema.Event{
		ID:          id,
		Title:       r.FormValue("title"),
		Description: r.FormValue("description"),
	}
	_, err = fsClient.Update(id, e)
	if err != nil {
		log.Printf("update: %v", err)
		http.Error(w, "Failed to update event", http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func deleteConfirmHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "id required", http.StatusBadRequest)
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil || id <= 0 {
		http.Error(w, "invalid id", http.StatusBadRequest)
		return
	}
	e, err := fsClient.Get(id)
	if err != nil {
		log.Printf("get: %v", err)
		http.Error(w, "Event not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := tpls.ExecuteTemplate(w, "delete.html", e); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func deleteHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Bad form", http.StatusBadRequest)
		return
	}
	id, err := strconv.Atoi(r.FormValue("id"))
	if err != nil || id <= 0 {
		http.Error(w, "invalid id", http.StatusBadRequest)
		return
	}
	if err := fsClient.Delete(id); err != nil {
		log.Printf("delete: %v", err)
		http.Error(w, "Failed to delete event", http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
