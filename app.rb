require 'mongo'
require 'faker'

# Words from Thesaurus.com for "wonderful"
words_of_admiration = [
  'admirable', 'amazing', 'astonishing', 'awesome', 'brilliant', 'cool',
  'enjoyable', 'excellent', 'fabulous', 'fantastic', 'fine', 'incredible',
  'magnificent', 'marvelous', 'outstanding', 'phenomenal', 'pleasant',
  'pleasing', 'remarkable', 'sensational', 'strange', 'superb', 
  'surprising', 'terrific', 'tremendous', 'wondrous', 'astounding',
  'awe-inspiring', 'divine', 'dynamite', 'groovy', 'miraculous', 'peachy',
  'prime', 'something else', 'staggering', 'startling', 'stupendous',
  'super', 'swell', 'too much', 'unhead of', 'wonderful'
]

client = Mongo::Client.new 'mongodb://localhost'
client = client.use 'test'

client[:catalog].update_one({_id: 1}, {"$set": {name: "BeeLink Mini Desktop"}}, upsert: true)
client[:catalog].update_one({_id: 2}, {"$set": {name: "iPhone 12 Pro Max"}}, upsert: true)
#
# client[:catalog].insert_many [
#   {name: "BeeLink Mini Desktop"},
#   {name: "iPhone 12 Pro Max"}
# ]

3.times {
  word_of_admiration = words_of_admiration[rand(words_of_admiration.length-1)]
  client[:catalog].update_one(
    {name: "BeeLink Mini Desktop"},
    {"$push": {reviews: {text: "This is #{word_of_admiration}", author: Faker::Name.name}}, "$inc": {review_count: 1}}
  )
}

30.times {
  word_of_admiration = words_of_admiration[rand(words_of_admiration.length-1)]
  prod_doc = client[:catalog].find(name: "iPhone 12 Pro Max").first
  
  # TODO Make the 10 a variable defined on top of the code
  if prod_doc.fetch(:review_count, 0) < 10
    client[:catalog].update_one(
      {name: "iPhone 12 Pro Max"},
      {"$push": {reviews: {text: "This is #{word_of_admiration}", author: Faker::Name.name}}, "$inc": {review_count: 1}},
      {upsert: true}
    )
  else
    client[:catalog].update_one(
      {name: "iPhone 12 Pro Max"},
      {"$set": {review_has_more: true}}
    )
    client[:catalog_reviews].insert_one(
      {name: "iPhone 12 Pro Max",
       review: {text: "This is #{word_of_admiration}", author: Faker::Name.name}}
    )
  end
}
client.close

puts "Look at the catalog and catalog_reviews collections in the test database"
