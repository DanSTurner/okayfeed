# OkayFeed! An acceptable place to aggregate social media

Welcome to my repo for OkayFeed. This app, in conjunction with [the okayfeed-messaging service](https://github.com/DanSTurner/okayfeed-messaging), provides a tool for users to view posts from social media services in aggregate and to crosspost to them.

### Features
* User accounts
* Email password recovery
* Authentication with Twitter, Facebook and Flickr
* Posting or crossposting to these services
* Background refresh of feeds
* Live notification and display of new posts


### Technologies used
1. Rails
2. Devise for user management
3. Omniauth
4. Koala, Twitter, and Flickraw for API clients
5. Sucker_punch for background feed refreshing
6. Private_pub for a Faye messaging server/websockets
7. Bootstrap
8. jQuery