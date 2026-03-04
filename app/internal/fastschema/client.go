package fastschema

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
)

const defaultBaseURL = "http://localhost:8000"

// Client calls FastSchema REST API for a single schema (e.g. "event").
type Client struct {
	baseURL string
	schema  string
	http    *http.Client
}

// NewClient returns a client for the given base URL (e.g. http://localhost:8000) and schema name.
func NewClient(baseURL, schema string) *Client {
	if baseURL == "" {
		baseURL = defaultBaseURL
	}
	if schema == "" {
		schema = "event"
	}
	return &Client{baseURL: baseURL, schema: schema, http: &http.Client{}}
}

// Event is a single record (matches FastSchema response and create/update payload).
type Event struct {
	ID          int    `json:"id,omitempty"`
	Title       string `json:"title"`
	Description string `json:"description,omitempty"`
	CreatedAt   string `json:"created_at,omitempty"`
	UpdatedAt   string `json:"updated_at,omitempty"`
}

// listResponse wraps list API response (items in data).
type listResponse struct {
	Data struct {
		Items []Event `json:"items"`
	} `json:"data"`
}

// singleResponse wraps create/update API response (single record in data).
type singleResponse struct {
	Data Event `json:"data"`
}

func (c *Client) contentPath(id int) string {
	if id == 0 {
		return fmt.Sprintf("%s/api/content/%s", c.baseURL, c.schema)
	}
	return fmt.Sprintf("%s/api/content/%s/%d", c.baseURL, c.schema, id)
}

// List returns all events (paginated; this uses default limit).
func (c *Client) List() ([]Event, error) {
	u, _ := url.Parse(c.contentPath(0))
	u.RawQuery = "limit=100"
	resp, err := c.http.Get(u.String())
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("list: %s: %s", resp.Status, string(body))
	}
	var out listResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, err
	}
	return out.Data.Items, nil
}

// Get fetches one event by ID.
func (c *Client) Get(id int) (Event, error) {
	resp, err := c.http.Get(c.contentPath(id))
	if err != nil {
		return Event{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return Event{}, fmt.Errorf("get: %s: %s", resp.Status, string(body))
	}
	var out singleResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return Event{}, err
	}
	return out.Data, nil
}

// Create creates a new event.
func (c *Client) Create(e Event) (Event, error) {
	body, _ := json.Marshal(e)
	resp, err := c.http.Post(c.contentPath(0), "application/json", bytes.NewReader(body))
	if err != nil {
		return Event{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		b, _ := io.ReadAll(resp.Body)
		return Event{}, fmt.Errorf("create: %s: %s", resp.Status, string(b))
	}
	var out singleResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return Event{}, err
	}
	return out.Data, nil
}

// Update updates an existing event (PUT).
func (c *Client) Update(id int, e Event) (Event, error) {
	body, _ := json.Marshal(e)
	req, _ := http.NewRequest(http.MethodPut, c.contentPath(id), bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.http.Do(req)
	if err != nil {
		return Event{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return Event{}, fmt.Errorf("update: %s: %s", resp.Status, string(b))
	}
	var out singleResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return Event{}, err
	}
	return out.Data, nil
}

// Delete deletes an event.
func (c *Client) Delete(id int) error {
	req, _ := http.NewRequest(http.MethodDelete, c.contentPath(id), nil)
	resp, err := c.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		b, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("delete: %s: %s", resp.Status, string(b))
	}
	return nil
}
