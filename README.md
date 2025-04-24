# good-night
Track users when they go to bed and when they wake up

## Asumptions:
- Does not handle authentication, use `current_user_id` in request body for simulation
- Does not implement user registration

## Versioning:
Ruby: 3.3.5
Rails: 7.2.2.1
Gem: 3.5.8
Bundler: 2.5.16

## Installation:
- `bundle install`
- `rake db:create`
- `rake db:migrate`
- `rake db:seed`

## Running app:
- `rails s`

## Running test and see coverage:
- `bundle exec rspec spec`

Note: Open the `coverage/index.html` file in your browser to view the detailed coverage report.

## Available endpoints
### 1. Get bed time histories for all following users
**Description**: An API endpoint to fetch last week's bed time history for all following users.<br />
**Host:** `localhost:3000/api/v1/bed_time/history`<br />
**Method:** `GET`<br />
**Request body:**<br />
```
{
    "current_user_id": 1,     // User ID to simulate authentication, required
    "page_size": 4,           // Number of records in a page, default is 10, optional
    "page_after": "25540-12", // Use next_cursor value from response body to access next page, optional
    "page_before": "22975-9"  // Use previous_cursor value from response body to to access previous page, optional
}
```
**Response body:**
```
{
    "data": [
        {
            "id": 8,
            "user_id": 2,
            "user_name": "Bob",
            "bed_time": "2025-04-18T20:19:21.308Z",
            "wake_up_time": "2025-04-19T08:22:00.268Z",
            "duration": 43358
        },
        {
            "id": 7,
            "user_id": 2,
            "user_name": "Bob",
            "bed_time": "2025-04-19T21:37:55.892Z",
            "wake_up_time": "2025-04-20T09:28:22.111Z",
            "duration": 42626
        },
        {
            "id": 12,
            "user_id": 3,
            "user_name": "Charlie",
            "bed_time": "2025-04-19T06:01:05.146Z",
            "wake_up_time": "2025-04-19T13:06:45.261Z",
            "duration": 25540
        }
    ],
    "pagination": {
        "next_cursor": "25540-12",
        "previous_cursor": null,
        "page_size": 3
    }
}
```

### 2. Set bed time and wake up time
**Description:** An API endpoint to set bed time and wake up time <br />
#### 2.1. Set bed time
**Host:** `localhost:3000/api/v1/bed_time/set_unset`<br />
**Method:** POST<br />
**Request body:**
```
{
    "current_user_id": 1, // User ID to simulate authentication, required
    "type": "bed_time"    // action type, accepted values: [wake_up, bed_time], required
}
```
**Response body:**
```
{
    "message": "bed_time successfully set at 2025-04-23 06:42:14 +0700"
}
```

#### 2.2. Set wake up time
**Host:** `localhost:3000/api/v1/bed_time/set_unset` <br />
**Method:** POST <br />
**Request body:**
```
{
    "current_user_id": 1, // User ID to simulate authentication, required
    "type": "wake_up"     // action type, accepted values: [wake_up, bed_time], required
}
```
**Response body:**
```
{
    "message": "wake_up successfully set at 2025-04-23 06:42:30 +0700"
}
```

### 3. Follow and Unfollow User API
**Description:** An API endpoint to follow and unfollow other user. <br/>

#### 3.1. Follow user
**Host:** `localhost:3000/api/v1/user/relations` <br/>
**Method:** POST <br/>
**Request body:**
```
{
    "current_user_id": 1,   // User ID to simulate authentication, required
    "target_user_id": 2,    // User ID, user want to follow, required
    "user_action": "follow" // User action, accepted values: [follow, unfollow], required
}
```
**Response body:**
```
{
    "message": "you have successfully follow user 2"
}
```

#### 3.2. Unfollow user
**Host:** `localhost:3000/api/v1/user/relations` <br/>
**Method:** POST <br/>
**Request body:**
```
{
    "current_user_id": 1,       // User ID to simulate authentication, required
    "target_user_id": 2,        // User ID, user want to unfollow, required
    "user_action": "unfollow"   // User action, accepted values: [follow, unfollow], required
}
```
**Response body:**
```
{
    "message": "you have successfully unfollow user 2"
}
```

### 4. Get list of followers
**Description:** An API endpoint to fetch list all followers. <br/>
**Host:** `localhost:3000/api/v1/user/relations` <br/>
**Method:** GET <br/>
**Request body:**
```
{
    "current_user_id": 4,         // User ID to simulate authentication, required
    "relation_type": "followers", // Relation type, accepted values: [following, followers], required
    "page_size": 1,               // Number of records in a page, default is 10, optional
    "page_after": 6,              // Next page cursor, optional
    "page_before": 5              // Next page cursor, optional
}
```
**Response body:**
```
{
    "data": [
        {
            "id": 1,
            "name": "Alice",
            "created_at": "2025-04-22T14:19:45.759Z",
            "updated_at": "2025-04-22T14:19:45.759Z"
        }
    ],
    "pagination": {
        "next_cursor": null,
        "previous_cursor": null,
        "per_page": 10
    }
}
```

### 6. Get list of following
**Description:** An API endpoint to fetch list of following users. <br/>
**Host:** `localhost:3000/api/v1/user/relations` <br/>
**Method:** GET <br/>
**Request body:**
```
{
    "current_user_id": 4,         // User ID to simulate authentication, required
    "relation_type": "following", // Relation type, accepted values: [following, followers], required
    "page_size": 1,               // Number of records in a page, default is 10, optional
    "page_after": 6,              // Use next_cursor value from response body to access next page, optional
    "page_before": 5              // Use previous_cursor value from response body to access previous page, optional
}
```
**Response body:**
```
{
    "data": [
        {
            "id": 3,
            "name": "Charlie",
            "created_at": "2025-04-22T14:19:45.861Z",
            "updated_at": "2025-04-22T14:19:45.861Z"
        }
    ],
    "pagination": {
        "next_cursor": null,
        "previous_cursor": null,
        "per_page": 10
    }
}
```