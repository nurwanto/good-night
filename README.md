# good-night
Track users when they go to bed and when they wake up

## Asumptions:
- Does not handle authentication, use `current_user_id` in request body for simulation
- Does not implement user registration

## Versioning:
Ruby: 3.3.5 <br>
Rails: 7.2.2.1 <br>
Gem: 3.5.8 <br>
Bundler: 2.5.16 <br>

## Installation:
- Copy `.env.example` file and rename it to `.env` file
- Update database config in `.env` file
- `bundle install`
- `rake db:create`
- `rake db:migrate`

**Optional:**
- `rake db:seed` to create sample data <br>
or <br>
- `ruby tmp/adhoc_scripts/generate_dummy_data.rb` to generate large dummy data <br>
Note: please change the parameter values according to your needs. <br>
`generate_dummy_data(data_size, batch_size)` <br>
e.g. `generate_dummy_data(1_000_000, 10_000)`

## Running app:
- `rails s`

## Running test and see test coverage:
- `bundle exec rspec spec`

sample output:
```
% bundle exec rspec spec

........................................

Finished in 1.24 seconds (files took 6.66 seconds to load)
40 examples, 0 failures

Coverage report generated for RSpec to /Users/nxs/Documents/testing/good-night/coverage.
Line Coverage: 100.0% (204 / 204)
```
Note: Open the `/coverage/index.html` file in your browser to view the detailed coverage report.

## Load test result:
**Precondition:**
- `users` table has 2_000_003 records
- `user_followers` table has 3_000_004 records
- `bed_time_histories` table has 3_000_019 records
- Notebook RAM: 16GB

**Test result:**
Average response time around 35ms

## Available endpoints
### 1. Get bed time histories for all following users
**Description**: An API endpoint to fetch last week's bed time history for all following users. <br>
**URL:** `{HOST}/api/v1/bed_time/history` <br>
**Method:** `GET` <br>
**Request body:**
```
{
    "current_user_id": 1,     // [required] User ID to simulate authentication
    "page_size": 4,           // [optional] Number of records in a page, default is 10
    "page_after": "25540-12", // [optional] Use next_cursor value from response body to access next page, if the value is "null" it means there is no next page
    "page_before": "22975-9"  // [optional] Use previous_cursor value from response body to to access previous page, if the value is "null" it means there is no previous page
}
```
**Response body:** <br>
Sample success response:
```
http_status: 200
body:
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

Sample fail response:
```
http_status: 400
body:
    {
        "error_message": "current_user_id should be exist"
    }
```

### 2. Set bed time and wake up time
**Description:** An API endpoint to set bed time and wake up time.
#### 2.1. Set bed time
**Host:** `{HOST}/api/v1/bed_time/set_unset` <br>
**Method:** POST <br>
**Request body:**
```
{
    "current_user_id": 1, // [required] User ID to simulate authentication
    "type": "bed_time"    // [required] Action type, accepted values: (wake_up, bed_time)
}
```

**Response body:** <br>
Sample success response
```
http_status: 200
body:
    {
        "message": "bed_time successfully set at 2025-04-23 06:42:14 +0700"
    }
```

Sample fail response
```
http_status: 400
body:
    {
        "error_message": "invalid type, accepted value [\"bed_time\", \"wake_up\"]"
    }
```

#### 2.2. Set wake up time
**Host:** `{HOST}/api/v1/bed_time/set_unset` <br>
**Method:** POST <br>
**Request body:**
```
{
    "current_user_id": 1, // [required] User ID to simulate authentication
    "type": "wake_up"     // [required] Action type, accepted values: (wake_up, bed_time)
}
```
**Response body:** <br>
Sample success response
```
http_status: 200
body:
    {
        "message": "wake_up successfully set at 2025-04-23 06:42:30 +0700"
    }
```

Sample fail response
```
http_status: 400
body:
    {
        "error_message": "invalid type, accepted value [\"bed_time\", \"wake_up\"]"
    }
```

### 3. Follow and Unfollow User API
**Description:** An API endpoint to follow and unfollow other user.

#### 3.1. Follow user
**Host:** `{HOST}/api/v1/user/relations` <br>
**Method:** POST <br>
**Request body:**
```
{
    "current_user_id": 1,   // [required] User ID to simulate authentication
    "target_user_id": 2,    // [requred] User ID, user want to follow
    "user_action": "follow" // [required] User action, accepted values: (follow, unfollow)
}
```
**Response body:** <br>
Sample success response
```
http_status: 200
body:
    {
        "message": "you have successfully follow user 2"
    }
```

Sample fail response
```
http_status: 400
body:
    {
        "error_message": "invalid user_actions, accepted user_action value [\"follow\", \"unfollow\"]"
    }
```

#### 3.2. Unfollow user
**Host:** `{HOST}/api/v1/user/relations` <br>
**Method:** POST <br>
**Request body:**
```
{
    "current_user_id": 1,       // [required] User ID to simulate authentication
    "target_user_id": 2,        // [required] User ID, user want to unfollow
    "user_action": "unfollow"   // [required] User action, accepted values: (follow, unfollow)
}
```
**Response body:** <br>
Sample success response
```
http_status: 200
body:
    {
        "message": "you have successfully unfollow user 2"
    }
```

Sample fail response
```
http_status: 400
body:
    {
        "error_message": "invalid user_actions, accepted user_action value [\"follow\", \"unfollow\"]"
    }
```

### 4. Get list of followers
**Description:** An API endpoint to fetch list all followers. <br>
**Host:** `{HOST}/api/v1/user/relations` <br>
**Method:** GET <br>
**Request body:**
```
{
    "current_user_id": 4,         // [required] User ID to simulate authentication
    "relation_type": "followers", // [required] Relation type, accepted values: (following, followers)
    "page_size": 1,               // [optional] Number of records in a page, default is 10
    "page_after": 6,              // [optional] Use next_cursor value from response body to access next page, if the value is "null" it means there is no next page
    "page_before": 5              // [optional] Use previous_cursor value from response body to to access previous page, if the value is "null" it means there is no previous page
}
```
**Response body:** <br>
Sample success response
```
http_status: 200
body:
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

Sample fail response
```
http_status: 400
body:
    {
        "error_message": "invalid relation_type, accepted relation_type value [\"followers\", \"following\"]"
    }
```

### 6. Get list of following
**Description:** An API endpoint to fetch list of following users. <br>
**Host:** `{HOST}/api/v1/user/relations` <br>
**Method:** GET <br>
**Request body:**
```
{
    "current_user_id": 4,         // [required] User ID to simulate authentication
    "relation_type": "following", // [required] Relation type, accepted values: [following, followers]
    "page_size": 1,               // [optional] Number of records in a page, default is 10
    "page_after": 6,              // [optional] Use next_cursor value from response body to access next page, if the value is "null" it means there is no next page
    "page_before": 5              // [optional] Use previous_cursor value from response body to to access previous page, if the value is "null" it means there is no previous page
}
```
**Response body:** <br>
Sample success response
```
http_status: 200
body:
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

Sample fail response
```
http_status: 400
body:
    {
        "error_message": "invalid relation_type, accepted relation_type value [\"followers\", \"following\"]"
    }
```
