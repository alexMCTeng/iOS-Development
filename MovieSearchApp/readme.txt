Movie Search App.

The app has 3 tabs in the tab bar, movies, favorite, and setting. Each of them has custom image.
Pull the data from TMDB using the API and populated into a collection view with 2 columns. The search number is 20 movies. The JSON results are process using Codable protocol.
User can see the tile and image for each movie.
All the images are cached into an array for smooth scrolling. And the cells can be reused.
Selecting a movie will push a DetailedViewController onto the navigation stack with larger image and more info, release date, movie overview, and average vote rating.
The user can change the search query by editing the text in search bar.
When performing the query a spinner will show when data is pulled from the API. During the time, user can still use the other function like go to the setting, go to the favorite movie list, the query does not lock up the user interface.
User can save/delete a movie into/from the favorite list.
Favorite list is maintained between app launches (data saved locally).
Attribute TMDb as the source of the movie data.

Creative portion:

1. Main Page
When there's no search query, the main page will display movies according to the popularity in descending order. Also, when users scroll down, as each query will only get 20 results back from the API, once the scroll reach the bottom of the movie list, additional query will be executed to get more data. A spinner will show up when querying more data and perform the setup for the collection view to display.

The whole operation will not lock up the user interface, users can still traverse in the app when the query is done in the background.

After the search, if users want to go back to main page, can simply clear out the search bar textfield and click search. Or, users can go to Setting tab and click save changes, the main page will be displayed.

2. Detailed View Controllers from the Movie tab (main page) and Favorite tab
Users can see detailed info of a movie not just from the Movie tab by tapping the cell.  When users in Favorite tab, users can get the detailed info by tapping the table view cell as well.

3. Synchronization among View Controllers
As mention above, there are 2 detailed view controllers, one is in the Movie tab, the other is in the Favorite tab. When users remove a movie from favorite movie list, the favorite movie list is updated and all the information that relates to the favorite movie will be update automatically and immediately. 

For example, users remove a movie from favorite in Favorite tab, and users can add it right back to the favorite in Movie tab without additional waiting or tapping to the other view.

4. All Information about Favorite Movies is Saved Locally.
When there's no internet connection, users can still see all the info about their favorite movies, including title, poster, rating, overview, and release date.

5. Check Internet Connection
When users try to search a movie, scroll down the main page and it needs to query more data from the API, if there's no Internet connection, an alert will pup out to remind the users.

6. Enable/Disable Adult Content. Change Language
In the Setting tab, users can choose whether display the movies that have adult content. Also, users are allowed to search movies in different languages. 
Once there's a change in Setting tab, the Movie tab will be updated accordingly without any additional tap.

7. Prevent accidental crashes
When users trying to do things in a short amount of time, for example, when scrolling down the main page and the app is querying more data to display, if users try to go to setting tab and make changes, there's a chance the app might crash. As there are two methods are trying to manipulate the arrays store the data.
In order to prevent that from happening, I added a variable called "isLoading", when isLoading is true, there will be an alert pop out to let the users know the loading is in action, please try again later, and the app will finish the previous request first.

Also, there's a chance that, when users regain internet access, and make a query immediately, the query may be completed but the image might not be able to load or the data cannot be accessed, if that happens, I use "guard let" for the data variable which is feed by the URL. For the image, I choose to display the "error" image.