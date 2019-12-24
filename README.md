# RestRails
Rails Plugin for quick intelligent API Creation by Tuitu Technology Solutions

## How To Start

1. Add To Gemfile: `gem 'rest_rails'`
2. Bundle Install: `bundle install`
3. Install RestRails:  `rails g rest_rails:install`
4. Modify initializer and/or mounted route.

## How To Use

RestRails will automatically create a base API for all standard CRUD actions.
Just one line of code to implement a powerful REST API.

For Example's sake, let's take the following schema:

- **articles:** *title, description, content*
- **comments:** *article_id, content*

Further more, as per activestorage convention, **Article** *has_one_attached :feature_image* & *has_many_attached :content_images*

Let's say we mount RestRails at `/api/v1`, the Following routes are included:
- index routes:  `GET /api/v1/articles`, `GET /api/v1/comments`
- show routes: `GET /api/v1/articles/:id`, `GET /api/v1/comments/:id`
- create routes: `POST /api/v1/articles`, `POST /api/v1/comments`
- update routes: `PATCH /api/v1/articles/:id`, `PATCH /api/v1/comments/:id`
- destroy routes: `DELETE /api/v1/articles/:id`, `DELETE /api/v1/comments/:id`
- fetch_column routes: `GET /api/v1/articles/:id/:column_name`, `GET /api/v1/comments/:id/:column_name`
- attach routes *if using active_storage* `POST /api/v1/articles/:id/attach/:attachment_name`, `POST /api/v1/comments/:id/attach/:attachment_name`
- unattach *if using active_storage* `DELETE /api/v1/articles/:id/unattach/:attachment_id`, `POST /api/v1/comments/:id/unattach/:attachment_id`

### INDEX:  GET '/table_name'
GET '/articles' will return a JSON response as follows:
```
{
  "code": 200,
  "objects": [
    {
      "id": 1,
      "created_at": "2019-08-27T08:22:19.357Z",
      "updated_at": "2019-08-27T08:22:19.499Z",
      "title": "Discourse on Dystopian Non Fiction",
      "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
      "content": "Wow, the reader actually clicked! Now let me brainwash him with this heavily opinionated article based on a myriad of unverified sources with the credibility of a personified M&M's...",
      "feature_image": {
        "attachment_id": 1,
        "url": "http://localhost:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsib--f573ab9452c272881fb/jopmqH0.jpg"
      },
      "content_images": [
        {
          "attachment_id": 3,
          "url": "http://localhost:3000/rails/active_storage/blobs/sjfioadifo-8fdjsfaj/fjso.jpg"
        }, {
          "attachment_id": 12,
          "url": "http://localhost:3000/rails/active_storage/blobs/fjiods--k0f09fs/jfdsjk.jpg"
        }
      ]
    },
    {...},
    {...},
    ...
  ],
  "count": 100,
  "total": 1300
}
```

The index REST API is by *default* paginated by 100. To go through pages, add the following params to the GET path:

`page=<a_number>`

ex:  '/api/v1/articles?page=2'

Models can also be filtered by a very basic WHERE query param structure.

For Article, the index API point can receive the following paramters:

param | type | example | notes
----- | ---- | ------- | ------
page  | *Integer* | page=2 | Will paginate by 100 per page.
article[title] | *String* | article[title]=Some+Title | Will match articles with titles same as the value.
article\[title\]\[\] | *Array* | article\[title\]\[\]=SomeTitle&article\[title\]\[\]=SomeOtherTitle | Will match articles with title of 'SomeTitle' OR 'SomeOtherTitle'
article[description] | *String* | article[description]=Some+Description | Will match articles with descriptions same as the value.
article\[description\]\[\] | *Array* | article\[description\]\[\]=SomeDescription&article\[description\]\[\]=SomeOtherDescription | Will match articles with description of 'SomeDescription' OR 'SomeOtherDescription'
article[content] | *String* | article[content]=Some+Content | Will match articles with contents same as the value.
article\[content\]\[\] | *Array* | article\[content\]\[\]=SomeContent&article\[content\]\[\]=SomeOtherContent | Will match articles with content of 'SomeContent' OR 'SomeOtherContent'

### SHOW:  GET '/table_name/:id'
GET '/articles/1' will return a JSON response as follows:
```
{
  "code": 200,
  "object": {
    "id": 1,
    "created_at": "2019-08-27T08:22:19.357Z",
    "updated_at": "2019-08-27T08:22:19.499Z",
    "title": "Discourse on Dystopian Non Fiction",
    "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
    "content": "Wow, the reader actually clicked! Now let me brainwash him with this heavily opinionated article based on a myriad of unverified sources with the credibility of a personified M&M's...",
    "feature_image": {
      "attachment_id": 1,
      "url": "http://localhost:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsib--f573ab9452c272881fb/jopmqH0.jpg"
    },
    "content_images": [
      {
        "attachment_id": 3,
        "url": "http://localhost:3000/rails/active_storage/blobs/sjfioadifo-8fdjsfaj/fjso.jpg"
      }, {
        "attachment_id": 12,
        "url": "http://localhost:3000/rails/active_storage/blobs/fjiods--k0f09fs/jfdsjk.jpg"
      }
    ]
  }
}
```

### CREATE:  POST '/table_name'

The create paths enforce Rails **strong params**. So only properly structured requests will be allowed.
POST '/articles' can accept a payload in the following structure:

```
  {
    "article" {
      "title": "Discourse on Dystopian Non Fiction",
      "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
      "content": "Wow, the reader actually clicked! Now let me brainwash him with this heavily opinionated article based on a myriad of unverified sources with the credibility of a personified M&M's..."
    }
  }
```

If successful (and passes your ActiveRecord validations), the response will be as follows:

```
{
  "code": 200,
  "msg": "success",
  "object": {
    "id": 1,
    "created_at": "2019-08-27T08:22:19.357Z",
    "updated_at": "2019-08-27T08:22:19.357Z",
    "title": "Discourse on Dystopian Non Fiction",
    "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
    "content": "Wow, the reader actually clicked! Now let me brainwash him with this heavily opinionated article based on a myriad of unverified sources with the credibility of a personified M&M's...",
    "feature_image": null,
    "content_images": []
  }
}
```

**Note:**  If you are using forms to submit data w/ attachments via activestorage, you can also add attachments to the payload sent, as long as it matches the naming of your activestorage attachment, and the form submission content-type is multipart/form_data.

```
  {
    "article" {
      "title": "Discourse on Dystopian Non Fiction",
      "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
      "feature_image": <uploaded_file>
    }
  }
```

### UPDATE:  PATCH '/table_name/:id'

The update paths enforce Rails **strong params**. So only properly structured requests will be allowed.
PATCH '/articles/1' can accept a payload in the following structure (with one or more columns to be updated):

```
  {
    "article" {
      "title": "Discourse on Dystopian Non Fiction",
      "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
      "content": "Wow, the reader actually clicked! Now let me brainwash him with this heavily opinionated article based on a myriad of unverified sources with the credibility of a personified M&M's..."
    }
  }
```

If successful (and passes your ActiveRecord validations), the response will be as follows:

```
{
  "code": 200,
  "msg": "success",
  "object": {
    "id": 1,
    "created_at": "2019-08-27T08:22:19.357Z",
    "updated_at": "2019-08-27T08:22:19.357Z",
    "title": "Discourse on Dystopian Non Fiction",
    "description": "This is an abstract description used to mislead readers into clicking on the article and take a deeper read.",
    "content": "Wow, the reader actually clicked! Now let me brainwash him with this heavily opinionated article based on a myriad of unverified sources with the credibility of a personified M&M's...",
    "feature_image": null,
    "content_images": []
  }
}
```

**Note:**  If you are using forms to submit data w/ attachments via activestorage, you can also add attachments to the payload sent, as long as it matches the naming of your activestorage attachment, and the form submission content-type is multipart/form_data.

```
  {
    "article" {
      "title": "Discourse on Dystopian Non Fiction",
      "feature_image": <uploaded_file>
    }
  }
```

### DESTROY:  DELETE '/table_name'

DELETE '/articles/1' only needs the ID number.

If successful (and passes your ActiveRecord validations), the response will be as follows:

```
{
  "code": 200,
  "msg": "success"
}
```

**Note:**  If you are using activestorage, the destroy process will also automatically destroy attachments from your bucket.

### FETCH_COLUMN:  GET '/table_name/:id/:column_name'

GET '/articles/1/title'

If column exists, the response will be as follows:

```
{
  "code": 200,
  "msg": "success",
  "value": "Discourse on Dystopian Non Fiction"
}
```

**Note:**  If you are using activestorage, you will return the following for has_one_attached:

```
{
  "code": 200,
  "msg": "success",
  "value": {
    "attachment_id": 1,
    "url": "http://localhost:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsib--f573ab9452c272881fb/jopmqH0.jpg"
  }
}
```
And for has_many_attached:

```
{
  "code": 200,
  "msg": "success",
  "value": [
    {
      "attachment_id": 3,
      "url": "http://localhost:3000/rails/active_storage/blobs/sjfioadifo-8fdjsfaj/fjso.jpg"
    },
    {
      "attachment_id": 12,
      "url": "http://localhost:3000/rails/active_storage/blobs/fjiods--k0f09fs/jfdsjk.jpg"
    }
  ]
}
```

## ACTIVESTORAGE ATTACHMENTS

For activestorage attachment support, the following two routes are added to models using activestorage:

`/table_name/:id/attach/:attachment_name` and `/table_name/:id/unattach/:attachment_id`

### ATTACH:  POST '/table_name/:id/attach/:attachment_name'

The routes generated for the rest API are based on the naming provided in your ActiveRecord model when using activestorage.

- Supports both has_one_attached & has_many_attached.

In the articles example above, this would be: "/api/v1/articles/attach/feature_image"

The payload structure in this case needs only to be:
```
{
  attachment: <file_uploaded>
}
```

If successful, the response will be as follows:

```
{
  "code": 200,
  "msg": "success"
}
```

### UNATTACH:  DELETE '/table_name/:id/unattach/:attachment_id'

*\* Note, Response will fail if the attachment_id provided does not belong to the object.*

If successful, the response will be as follows:

```
{
  "code": 200,
  "msg": "success"
}
```






## Contribution
Here are some features in need of development.
- Add way to "protect columns" (i.e. exclude columns from permitted params for model's update/create API points).
- Support different popular attachment gems.
- Add Locale fetching based on page-routes.
