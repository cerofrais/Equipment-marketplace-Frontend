# Equipment Rental Marketplace API - Integration Guide

## Overview

This document provides a comprehensive guide for integrating with the Equipment Rental Marketplace API. The API enables customers to request equipment rentals and connects them with local vendors through a quote-based marketplace system.

**API Version:** 2.0.0  
**Base URL:** `http://localhost:8000` (Development)  
**Documentation:** 
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Equipment Types](#equipment-types)
3. [Rental Requests](#rental-requests)
4. [Quotes](#quotes)
5. [Webhooks](#webhooks)
6. [Legacy Equipment Endpoints](#legacy-equipment-endpoints)
7. [Data Models](#data-models)
8. [Error Handling](#error-handling)
9. [Rate Limiting & Best Practices](#rate-limiting--best-practices)

---

## Authentication

The API uses phone number-based OTP authentication with JWT tokens.

### Base Path
`/api/v1/auth`

### Endpoints

#### 1. Send OTP

Send an OTP code to a phone number for authentication.

**Endpoint:** `POST /api/v1/auth/send-otp`

**Request Body:**
```json
{
  "phone_number": "+14155551234"
}
```

**Parameters:**
- `phone_number` (string, required): Phone number in E.164 format (must match pattern: `^\+?[1-9]\d{9,14}$`)

**Response:** `200 OK`
```json
{
  "message": "OTP sent successfully"
}
```

**Error Responses:**
- `500 Internal Server Error`: Failed to send OTP or server error

---

#### 2. Verify OTP

Verify OTP and receive JWT tokens for authenticated requests.

**Endpoint:** `POST /api/v1/auth/verify-otp`

**Request Body:**
```json
{
  "phone_number": "+14155551234",
  "otp": "123456"
}
```

**Parameters:**
- `phone_number` (string, required): Phone number that received the OTP
- `otp` (string, required): 4-6 digit OTP code

**Response:** `200 OK`
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid OTP
- `404 Not Found`: User not found
- `500 Internal Server Error`: Server error

---

#### 3. Refresh Token

Refresh the access token using a refresh token.

**Endpoint:** `POST /api/v1/auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Parameters:**
- `refresh_token` (string, required): Valid refresh token

**Response:** `200 OK`
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or expired refresh token, or user inactive

---

#### 4. Logout

Logout and invalidate tokens.

**Endpoint:** `POST /api/v1/auth/logout`

**Request Body:**
```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Response:** `200 OK`
```json
{
  "message": "Successfully logged out"
}
```

---

### Using Authentication Tokens

For all authenticated endpoints, include the access token in the Authorization header:

```
Authorization: Bearer <access_token>
```

**Example:**
```bash
curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  http://localhost:8000/api/v1/rental-requests/my-requests
```

---

## Equipment Types

Browse and search available equipment types for rental.

### Base Path
`/api/v1/equipment-types`

### Endpoints

#### 1. List Equipment Types

Get a list of all available equipment types with optional filtering.

**Endpoint:** `GET /api/v1/equipment-types`

**Query Parameters:**
- `category` (string, optional): Filter by equipment category
- `skip` (integer, optional, default=0): Number of records to skip for pagination
- `limit` (integer, optional, default=100, max=1000): Maximum records to return

**Example Requests:**
```bash
# Get all equipment types
GET /api/v1/equipment-types

# Filter by category
GET /api/v1/equipment-types?category=construction

# With pagination
GET /api/v1/equipment-types?skip=0&limit=20
```

**Response:** `200 OK`
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Excavator",
    "category": "construction",
    "description": "Heavy construction equipment for digging and excavation work"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "name": "Forklift",
    "category": "warehouse",
    "description": "Industrial forklift for material handling"
  }
]
```

---

#### 2. Get Equipment Type by ID

Retrieve details of a specific equipment type.

**Endpoint:** `GET /api/v1/equipment-types/{equipment_type_id}`

**Path Parameters:**
- `equipment_type_id` (UUID, required): Equipment type ID

**Example Request:**
```bash
GET /api/v1/equipment-types/550e8400-e29b-41d4-a716-446655440000
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Excavator",
  "category": "construction",
  "description": "Heavy construction equipment for digging and excavation work"
}
```

**Error Responses:**
- `404 Not Found`: Equipment type not found

---

#### 3. Create Equipment Type

Create a new equipment type (Admin endpoint).

**Endpoint:** `POST /api/v1/equipment-types`

**Request Body:**
```json
{
  "name": "Bulldozer",
  "category": "construction",
  "description": "Powerful tracked equipment for earthmoving"
}
```

**Parameters:**
- `name` (string, required): Equipment type name
- `category` (string, optional): Equipment category
- `description` (string, optional): Equipment description

**Response:** `201 Created`
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "name": "Bulldozer",
  "category": "construction",
  "description": "Powerful tracked equipment for earthmoving"
}
```

---

## Rental Requests

Create and manage equipment rental requests.

### Base Path
`/api/v1/rental-requests`

### Authentication Required
All rental request endpoints require authentication. Include the Bearer token in the Authorization header.

### Endpoints

#### 1. Create Rental Request

Submit a new equipment rental request. The system will automatically match with nearby vendors and send notifications.

**Endpoint:** `POST /api/v1/rental-requests`  
**Authentication:** Required

**Request Body:**
```json
{
  "equipment_type_id": "550e8400-e29b-41d4-a716-446655440000",
  "zip_code": "94102",
  "start_date": "2026-02-01T09:00:00Z",
  "end_date": "2026-02-05T17:00:00Z"
}
```

**Parameters:**
- `equipment_type_id` (UUID, required): ID of the equipment type to rent
- `zip_code` (string, required): ZIP code for equipment delivery/pickup
- `start_date` (datetime, required): Rental start date/time (ISO 8601 format)
- `end_date` (datetime, required): Rental end date/time (ISO 8601 format)

**Response:** `201 Created`
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440010",
  "user_id": "990e8400-e29b-41d4-a716-446655440020",
  "equipment_type_id": "550e8400-e29b-41d4-a716-446655440000",
  "zip_code": "94102",
  "start_date": "2026-02-01T09:00:00Z",
  "end_date": "2026-02-05T17:00:00Z",
  "status": "pending",
  "created_at": "2026-01-29T15:30:00Z"
}
```

**Process Flow:**
1. System validates equipment type exists
2. Converts ZIP code to GPS coordinates using geocoding
3. Creates rental request with status "pending"
4. Finds nearby vendors within 25km radius
5. Sends WhatsApp notifications to matched vendors

**Error Responses:**
- `400 Bad Request`: Invalid ZIP code
- `404 Not Found`: Equipment type not found
- `401 Unauthorized`: Missing or invalid authentication token

---

#### 2. Get Rental Request Details

Retrieve details of a specific rental request including all vendor quotes.

**Endpoint:** `GET /api/v1/rental-requests/{request_id}`  
**Authentication:** Required

**Path Parameters:**
- `request_id` (UUID, required): Rental request ID

**Example Request:**
```bash
GET /api/v1/rental-requests/880e8400-e29b-41d4-a716-446655440010
```

**Response:** `200 OK`
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440010",
  "user_id": "990e8400-e29b-41d4-a716-446655440020",
  "equipment_type_id": "550e8400-e29b-41d4-a716-446655440000",
  "zip_code": "94102",
  "start_date": "2026-02-01T09:00:00Z",
  "end_date": "2026-02-05T17:00:00Z",
  "status": "quoted",
  "created_at": "2026-01-29T15:30:00Z",
  "quotes": [
    {
      "id": "aa0e8400-e29b-41d4-a716-446655440030",
      "rental_request_id": "880e8400-e29b-41d4-a716-446655440010",
      "vendor_id": "bb0e8400-e29b-41d4-a716-446655440040",
      "price": "1250.00",
      "notes": "Includes delivery and pickup",
      "response_type": "quote",
      "customer_status": "pending",
      "created_at": "2026-01-29T16:00:00Z"
    }
  ]
}
```

**Error Responses:**
- `404 Not Found`: Rental request not found
- `403 Forbidden`: Not authorized to view this request (not the owner)
- `401 Unauthorized`: Missing or invalid authentication token

---

#### 3. Get My Rental Requests

Retrieve rental request history for the authenticated user.

**Endpoint:** `GET /api/v1/rental-requests/my-requests`  
**Authentication:** Required

**Query Parameters:**
- `skip` (integer, optional, default=0): Number of records to skip
- `limit` (integer, optional, default=100, max=1000): Maximum records to return

**Example Request:**
```bash
GET /api/v1/rental-requests/my-requests?skip=0&limit=10
```

**Response:** `200 OK`
```json
[
  {
    "id": "880e8400-e29b-41d4-a716-446655440010",
    "user_id": "990e8400-e29b-41d4-a716-446655440020",
    "equipment_type_id": "550e8400-e29b-41d4-a716-446655440000",
    "zip_code": "94102",
    "start_date": "2026-02-01T09:00:00Z",
    "end_date": "2026-02-05T17:00:00Z",
    "status": "quoted",
    "created_at": "2026-01-29T15:30:00Z"
  },
  {
    "id": "880e8400-e29b-41d4-a716-446655440011",
    "user_id": "990e8400-e29b-41d4-a716-446655440020",
    "equipment_type_id": "660e8400-e29b-41d4-a716-446655440001",
    "zip_code": "94103",
    "start_date": "2026-01-15T08:00:00Z",
    "end_date": "2026-01-20T18:00:00Z",
    "status": "accepted",
    "created_at": "2026-01-10T12:00:00Z"
  }
]
```

**Status Values:**
- `pending`: Request submitted, waiting for quotes
- `quoted`: Vendors have submitted quotes
- `accepted`: Customer accepted a quote
- `completed`: Rental completed
- `cancelled`: Request cancelled

---

## Quotes

Manage vendor quotes for rental requests.

### Base Path
`/api/v1/quotes`

### Authentication Required
All quote endpoints require authentication.

### Endpoints

#### 1. Get Quotes for Request

Retrieve all vendor quotes for a specific rental request, sorted by price.

**Endpoint:** `GET /api/v1/quotes/request/{request_id}`  
**Authentication:** Required

**Path Parameters:**
- `request_id` (UUID, required): Rental request ID

**Example Request:**
```bash
GET /api/v1/quotes/request/880e8400-e29b-41d4-a716-446655440010
```

**Response:** `200 OK`
```json
[
  {
    "id": "aa0e8400-e29b-41d4-a716-446655440030",
    "rental_request_id": "880e8400-e29b-41d4-a716-446655440010",
    "vendor_id": "bb0e8400-e29b-41d4-a716-446655440040",
    "price": "1250.00",
    "notes": "Includes delivery and pickup. Equipment in excellent condition.",
    "response_type": "quote",
    "customer_status": "pending",
    "created_at": "2026-01-29T16:00:00Z",
    "vendor": {
      "id": "bb0e8400-e29b-41d4-a716-446655440040",
      "business_name": "ABC Equipment Rentals",
      "whatsapp_number": "+14155552345",
      "zip_code": "94105",
      "service_radius_km": "25.0",
      "is_active": true,
      "created_at": "2025-12-01T10:00:00Z"
    }
  },
  {
    "id": "aa0e8400-e29b-41d4-a716-446655440031",
    "rental_request_id": "880e8400-e29b-41d4-a716-446655440010",
    "vendor_id": "bb0e8400-e29b-41d4-a716-446655440041",
    "price": "1350.00",
    "notes": "Next day delivery available",
    "response_type": "quote",
    "customer_status": "pending",
    "created_at": "2026-01-29T16:15:00Z",
    "vendor": {
      "id": "bb0e8400-e29b-41d4-a716-446655440041",
      "business_name": "XYZ Rentals Inc",
      "whatsapp_number": "+14155553456",
      "zip_code": "94107",
      "service_radius_km": "30.0",
      "is_active": true,
      "created_at": "2025-11-15T09:00:00Z"
    }
  }
]
```

**Error Responses:**
- `404 Not Found`: Rental request not found
- `403 Forbidden`: Not authorized to view quotes for this request

---

#### 2. Accept Quote

Accept a vendor's quote. This automatically rejects all other quotes for the same request.

**Endpoint:** `POST /api/v1/quotes/{quote_id}/accept`  
**Authentication:** Required

**Path Parameters:**
- `quote_id` (UUID, required): Quote ID to accept

**Example Request:**
```bash
POST /api/v1/quotes/aa0e8400-e29b-41d4-a716-446655440030/accept
```

**Response:** `200 OK`
```json
{
  "message": "Quote accepted successfully"
}
```

**Process Flow:**
1. Updates quote status to "accepted"
2. Updates rental request status to "accepted"
3. Automatically rejects all other pending quotes for the same request

**Error Responses:**
- `404 Not Found`: Quote not found
- `403 Forbidden`: Not authorized to accept this quote (not the request owner)

---

#### 3. Reject Quote

Reject a vendor's quote.

**Endpoint:** `POST /api/v1/quotes/{quote_id}/reject`  
**Authentication:** Required

**Path Parameters:**
- `quote_id` (UUID, required): Quote ID to reject

**Example Request:**
```bash
POST /api/v1/quotes/aa0e8400-e29b-41d4-a716-446655440031/reject
```

**Response:** `200 OK`
```json
{
  "message": "Quote rejected successfully"
}
```

**Error Responses:**
- `404 Not Found`: Quote not found
- `403 Forbidden`: Not authorized to reject this quote

---

#### 4. Create Quote (Vendor Endpoint)

Create a vendor quote in response to a rental request. This endpoint is intended for vendor use.

**Endpoint:** `POST /api/v1/quotes`

**Request Body:**
```json
{
  "rental_request_id": "880e8400-e29b-41d4-a716-446655440010",
  "vendor_id": "bb0e8400-e29b-41d4-a716-446655440040",
  "price": "1250.00",
  "notes": "Includes delivery and pickup",
  "response_type": "quote"
}
```

**Parameters:**
- `rental_request_id` (UUID, required): Rental request ID
- `vendor_id` (UUID, required): Vendor ID
- `price` (decimal, required): Quote price
- `notes` (string, optional): Additional notes or terms
- `response_type` (string, required): Type of response (default: "quote")

**Response:** `201 Created`
```json
{
  "id": "aa0e8400-e29b-41d4-a716-446655440032",
  "rental_request_id": "880e8400-e29b-41d4-a716-446655440010",
  "vendor_id": "bb0e8400-e29b-41d4-a716-446655440040",
  "price": "1250.00",
  "notes": "Includes delivery and pickup",
  "response_type": "quote",
  "customer_status": "pending",
  "created_at": "2026-01-29T17:00:00Z"
}
```

**Error Responses:**
- `404 Not Found`: Rental request or vendor not found

---

## Webhooks

Handle incoming webhook events from external services.

### Base Path
`/api/v1/webhooks`

### Endpoints

#### 1. WhatsApp Webhook

Receive and process WhatsApp responses from vendors via Twilio/Meta.

**Endpoint:** `POST /api/v1/webhooks/whatsapp`

**Request Body:**
```json
{
  "message_id": "wamid.HBgNMTQxNTU1NTEyMzQ",
  "from": "+14155552345",
  "body": "QUOTE: $1250 for 5 days. Includes delivery.",
  "timestamp": "2026-01-29T16:00:00Z"
}
```

**Response:** `200 OK`
```json
{
  "message": "Webhook processed successfully"
}
```

**Notes:**
- This endpoint should be configured as the webhook URL in your WhatsApp provider settings
- Webhook signature validation should be implemented for security
- The request format depends on your WhatsApp provider (Twilio, Meta, etc.)

---

#### 2. WhatsApp Status Webhook

Track WhatsApp message delivery status updates.

**Endpoint:** `POST /api/v1/webhooks/whatsapp-status`

**Request Body:**
```json
{
  "message_id": "wamid.HBgNMTQxNTU1NTEyMzQ",
  "status": "delivered",
  "timestamp": "2026-01-29T15:35:00Z"
}
```

**Status Values:**
- `sent`: Message sent to WhatsApp servers
- `delivered`: Message delivered to recipient's device
- `read`: Message read by recipient
- `failed`: Message delivery failed

**Response:** `200 OK`
```json
{
  "message": "Status updated successfully"
}
```

---

## Legacy Equipment Endpoints

Legacy CRUD endpoints for equipment management (backward compatibility).

### Base Path
`/equipment`

### Endpoints

#### 1. Create Equipment

**Endpoint:** `POST /equipment/`

**Request Body:**
```json
{
  "name": "Excavator",
  "description": "Heavy-duty excavator for construction"
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "name": "Excavator",
  "description": "Heavy-duty excavator for construction",
  "created_at": "2026-01-29T10:30:00Z",
  "updated_at": "2026-01-29T10:30:00Z"
}
```

---

#### 2. Get All Equipment

**Endpoint:** `GET /equipment/`

**Query Parameters:**
- `skip` (integer, optional, default=0)
- `limit` (integer, optional, default=100, max=1000)

**Response:** `200 OK`
```json
{
  "total": 50,
  "skip": 0,
  "limit": 100,
  "items": [
    {
      "id": 1,
      "name": "Excavator",
      "description": "Heavy-duty excavator",
      "created_at": "2026-01-29T10:30:00Z",
      "updated_at": "2026-01-29T10:30:00Z"
    }
  ]
}
```

---

#### 3. Search Equipment

**Endpoint:** `GET /equipment/search`

**Query Parameters:**
- `q` (string, required): Search term
- `fields` (string, optional, default="name,description"): Fields to search
- `skip` (integer, optional, default=0)
- `limit` (integer, optional, default=100, max=1000)

**Response:** `200 OK`
```json
{
  "total": 5,
  "skip": 0,
  "limit": 10,
  "items": [
    {
      "id": 1,
      "name": "Excavator",
      "description": "Heavy-duty excavator",
      "created_at": "2026-01-29T10:30:00Z",
      "updated_at": "2026-01-29T10:30:00Z"
    }
  ]
}
```

---

#### 4. Get Equipment by ID

**Endpoint:** `GET /equipment/{equipment_id}`

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Excavator",
  "description": "Heavy-duty excavator",
  "created_at": "2026-01-29T10:30:00Z",
  "updated_at": "2026-01-29T10:30:00Z"
}
```

---

#### 5. Update Equipment

**Endpoint:** `PUT /equipment/{equipment_id}`

**Request Body:**
```json
{
  "name": "Heavy Excavator",
  "description": "Updated description"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Heavy Excavator",
  "description": "Updated description",
  "created_at": "2026-01-29T10:30:00Z",
  "updated_at": "2026-01-29T18:45:00Z"
}
```

---

#### 6. Delete Equipment

**Endpoint:** `DELETE /equipment/{equipment_id}`

**Response:** `200 OK`
```json
{
  "message": "Equipment deleted successfully"
}
```

---

## Data Models

### User
```json
{
  "id": "UUID",
  "phone_number": "string",
  "created_at": "datetime",
  "last_login": "datetime",
  "is_active": "boolean"
}
```

### Equipment Type
```json
{
  "id": "UUID",
  "name": "string",
  "category": "string",
  "description": "string"
}
```

### Vendor
```json
{
  "id": "UUID",
  "business_name": "string",
  "whatsapp_number": "string",
  "zip_code": "string",
  "service_radius_km": "decimal",
  "is_active": "boolean",
  "created_at": "datetime"
}
```

### Rental Request
```json
{
  "id": "UUID",
  "user_id": "UUID",
  "equipment_type_id": "UUID",
  "zip_code": "string",
  "location": "geography (POINT)",
  "start_date": "datetime",
  "end_date": "datetime",
  "status": "string",
  "created_at": "datetime"
}
```

**Status Values:**
- `pending`: Awaiting vendor quotes
- `quoted`: Received vendor quotes
- `accepted`: Quote accepted by customer
- `completed`: Rental completed
- `cancelled`: Request cancelled

### Vendor Quote
```json
{
  "id": "UUID",
  "rental_request_id": "UUID",
  "vendor_id": "UUID",
  "price": "decimal",
  "notes": "string",
  "response_type": "string",
  "customer_status": "string",
  "created_at": "datetime"
}
```

**Customer Status Values:**
- `pending`: Awaiting customer decision
- `accepted`: Quote accepted
- `rejected`: Quote rejected

---

## Error Handling

### Standard Error Response Format

```json
{
  "detail": "Error message describing what went wrong"
}
```

### HTTP Status Codes

| Status Code | Meaning |
|-------------|---------|
| 200 | OK - Request succeeded |
| 201 | Created - Resource successfully created |
| 400 | Bad Request - Invalid input or parameters |
| 401 | Unauthorized - Missing or invalid authentication |
| 403 | Forbidden - Authenticated but not authorized |
| 404 | Not Found - Resource doesn't exist |
| 500 | Internal Server Error - Server-side error |

### Common Error Scenarios

**Authentication Errors:**
```json
{
  "detail": "Invalid OTP"
}
```

**Authorization Errors:**
```json
{
  "detail": "Not authorized to view this request"
}
```

**Not Found Errors:**
```json
{
  "detail": "Equipment type not found"
}
```

**Validation Errors:**
```json
{
  "detail": "Invalid ZIP code"
}
```

---

## Rate Limiting & Best Practices

### Rate Limiting

Currently no rate limiting is enforced in development. Production deployments should implement:
- Authentication endpoints: 5 requests per minute per IP
- Standard endpoints: 100 requests per minute per user
- Webhook endpoints: Validated by signature

### Best Practices

#### 1. Authentication
- Store tokens securely (never in localStorage for web apps)
- Implement token refresh logic before expiration
- Handle 401 responses by refreshing tokens

```javascript
// Example token refresh logic
async function apiCall(url, options) {
  let response = await fetch(url, {
    ...options,
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      ...options.headers
    }
  });
  
  if (response.status === 401) {
    // Refresh token
    const refreshResponse = await fetch('/api/v1/auth/refresh', {
      method: 'POST',
      body: JSON.stringify({ refresh_token: refreshToken })
    });
    const { access_token } = await refreshResponse.json();
    accessToken = access_token;
    
    // Retry original request
    response = await fetch(url, {
      ...options,
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        ...options.headers
      }
    });
  }
  
  return response;
}
```

#### 2. Error Handling
- Always check response status codes
- Parse error messages from response body
- Implement exponential backoff for retries

#### 3. Date/Time Handling
- Always use ISO 8601 format (YYYY-MM-DDTHH:mm:ssZ)
- Send dates in UTC timezone
- Convert to local timezone on client side

#### 4. Pagination
- Use skip/limit parameters for large datasets
- Request only the data you need
- Cache results when appropriate

#### 5. Phone Numbers
- Always use E.164 format: +[country code][number]
- Validate format before sending to API
- Example: +14155551234

#### 6. Webhook Security
- Verify webhook signatures
- Use HTTPS endpoints
- Implement idempotency for webhook handlers
- Log all webhook requests for debugging

---

## Integration Examples

### Example 1: Complete Rental Request Flow

```javascript
// Step 1: Send OTP
const sendOTP = async (phoneNumber) => {
  const response = await fetch('http://localhost:8000/api/v1/auth/send-otp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone_number: phoneNumber })
  });
  return response.json();
};

// Step 2: Verify OTP
const verifyOTP = async (phoneNumber, otp) => {
  const response = await fetch('http://localhost:8000/api/v1/auth/verify-otp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone_number: phoneNumber, otp: otp })
  });
  const data = await response.json();
  return data; // Contains access_token and refresh_token
};

// Step 3: Get equipment types
const getEquipmentTypes = async () => {
  const response = await fetch('http://localhost:8000/api/v1/equipment-types');
  return response.json();
};

// Step 4: Create rental request
const createRentalRequest = async (accessToken, requestData) => {
  const response = await fetch('http://localhost:8000/api/v1/rental-requests', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    },
    body: JSON.stringify(requestData)
  });
  return response.json();
};

// Step 5: Get quotes
const getQuotes = async (accessToken, requestId) => {
  const response = await fetch(
    `http://localhost:8000/api/v1/quotes/request/${requestId}`,
    {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    }
  );
  return response.json();
};

// Step 6: Accept quote
const acceptQuote = async (accessToken, quoteId) => {
  const response = await fetch(
    `http://localhost:8000/api/v1/quotes/${quoteId}/accept`,
    {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${accessToken}` }
    }
  );
  return response.json();
};

// Usage
async function completeRentalFlow() {
  // Authenticate
  await sendOTP('+14155551234');
  const { access_token } = await verifyOTP('+14155551234', '123456');
  
  // Browse equipment
  const equipmentTypes = await getEquipmentTypes();
  const excavatorId = equipmentTypes.find(e => e.name === 'Excavator').id;
  
  // Create request
  const request = await createRentalRequest(access_token, {
    equipment_type_id: excavatorId,
    zip_code: '94102',
    start_date: '2026-02-01T09:00:00Z',
    end_date: '2026-02-05T17:00:00Z'
  });
  
  // Wait for quotes (in production, use polling or webhooks)
  await new Promise(resolve => setTimeout(resolve, 60000));
  
  // Get and accept best quote
  const quotes = await getQuotes(access_token, request.id);
  const bestQuote = quotes[0]; // Sorted by price
  await acceptQuote(access_token, bestQuote.id);
}
```

### Example 2: Python Integration

```python
import requests
from datetime import datetime, timedelta

class EquipmentMarketplaceClient:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.access_token = None
        self.refresh_token = None
    
    def send_otp(self, phone_number):
        response = requests.post(
            f"{self.base_url}/api/v1/auth/send-otp",
            json={"phone_number": phone_number}
        )
        return response.json()
    
    def verify_otp(self, phone_number, otp):
        response = requests.post(
            f"{self.base_url}/api/v1/auth/verify-otp",
            json={"phone_number": phone_number, "otp": otp}
        )
        data = response.json()
        self.access_token = data["access_token"]
        self.refresh_token = data["refresh_token"]
        return data
    
    def get_headers(self):
        return {"Authorization": f"Bearer {self.access_token}"}
    
    def create_rental_request(self, equipment_type_id, zip_code, start_date, end_date):
        response = requests.post(
            f"{self.base_url}/api/v1/rental-requests",
            headers=self.get_headers(),
            json={
                "equipment_type_id": equipment_type_id,
                "zip_code": zip_code,
                "start_date": start_date.isoformat() + 'Z',
                "end_date": end_date.isoformat() + 'Z'
            }
        )
        return response.json()
    
    def get_my_requests(self):
        response = requests.get(
            f"{self.base_url}/api/v1/rental-requests/my-requests",
            headers=self.get_headers()
        )
        return response.json()

# Usage
client = EquipmentMarketplaceClient()
client.send_otp("+14155551234")
client.verify_otp("+14155551234", "123456")

start = datetime.now() + timedelta(days=3)
end = start + timedelta(days=5)

request = client.create_rental_request(
    equipment_type_id="550e8400-e29b-41d4-a716-446655440000",
    zip_code="94102",
    start_date=start,
    end_date=end
)
```

---

## Support & Additional Resources

- **Swagger UI:** http://localhost:8000/docs (Interactive API documentation)
- **ReDoc:** http://localhost:8000/redoc (Alternative documentation format)
- **Health Check:** `GET /health`
- **Root Endpoint:** `GET /`

For issues or questions, please refer to the repository documentation or contact the development team.

---

**Last Updated:** January 29, 2026  
**API Version:** 2.0.0
