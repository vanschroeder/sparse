#### sparse.UserCollection
# Collection to retrieve and manage Parse User Objects
class sparse.Users extends sparse.Collection
  url:->
    "#{sparse.API_URI}/users"