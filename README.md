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

Further more, as per ActiveStorage convention, **Article** *has_one_attached :feature_image* & *has_many_attached :content_images*

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


## Contribution
Here are some features in need of development.
- Add way to "protect columns" (i.e. exclude columns from permitted params for model's update/create API points).
- Support different popular attachment gems.
- Add Locale fetching based on page-routes.
