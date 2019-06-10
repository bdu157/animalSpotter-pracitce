# Animal Spotter API

The base URL for this API is https://lambdaanimalspotter.vapor.cloud/api

--- 

### Sign Up

**Endpoint:** `/users/signup`

**Method:** `POST`

**Auth Required:** NO

Creates a user whose credentials can then be used to log in to the API, giving them a bearer token.

JSON should be POSTed in the following format: 

``` JSON
{
  "username": "Tim",
  "password": "Apple"
}
```

#### Success Response

**Code:** `200 OK`

--- 

### Log In

**Endpoint:** `/users/login`

**Method:** `POST`

**Auth Required:** NO

**Description:** After creating a user, you may log in to the API using the same credentials as you used to sign up. e.g:

``` JSON 
{
  "username": "Tim",
  "password": "Apple"
}
```

#### Success Response

**Code:** `200 OK`

The `token` may be used to authenticate a request.

``` JSON
{
  "id": 1,
  "token": "fsMd9aHpoJ62vo4OvLC79MDqd38oE2ihkx6A1KeFwek=",
  "userId": 1
}
```

---

### Get All Animal Names

**Endpoint:** `/animals/all`

**Method:** `GET`

**Auth Required:** YES

**Required Header:** 

| Key | Example Value | Description |
|---|---|---|
| `Authorization` | `Bearer fsMd9aHpoJ62vo4OvLC79MDqd38oE2ihkx6A1KeFwek` | "Bearer " + The token returned from logging in | 

**Description:** Returns an array with the name of every animal in the API.

#### Success Response

**Code:** `200 OK`

**Example Response:** 

``` JSON
[
  "Lion",
  "Zebra",
  "Flamingo",
]
```

#### Not Authenticated Response

**Code:** `401 Unauthorized`

**Description:** The user has not included their token in the `Authorization` header.

**Response:**

``` JSON
{
  "error": true,
  "reason": "User not authenticated."
}
```

---

### Get A Specfic Animal

**Endpoint:** `animals/animalName` where `animalName` is some animal's name.

**Method:** `GET`

**Auth Required:** YES

**Required Header:** 

| Key | Example Value | Description |
|---|---|---|
| `Authorization` | `Bearer fsMd9aHpoJ62vo4OvLC79MDqd38oE2ihkx6A1KeFwek` | "Bearer " + The token returned from logging in | 

#### Success Response

**Code:** `200 OK`

**Response:**

``` JSON
{
  "id": 1,
  "name": "Lion",
  "latitude": 41.0059666,
  "longitude": -8.596247,
  "timeSeen": 1476381432,
  "description": "A large tawny-colored cat that lives in prides, found in Africa and northwestern India. The male has a flowing shaggy mane and takes little part in hunting, which is done cooperatively by the females.",
  "imageURL": "https://user-images.githubusercontent.com/16965587/57208108-357e8000-6f8f-11e9-89fa-acd05e383c63.jpg",
}
```