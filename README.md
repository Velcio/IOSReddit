# IOSReddit
Dit project werd gecreëerd voor het OLOD Native Apps II: iOS
Met deze app kan er op reddit in beperkte mate worden bekeken:
  - Opvragen van 25 populaire subreddits
  - Laden van topics van deze subreddits, lijst met:
    - titel
    - datum
    - auteur
    - thumbnail
  - Bekijken van een topic
    - zelfde informatie als in de lijst en 
    - de inhoud als die werd meegegeven
    - of een link naar de inhoud

Om dit project te creëren heb ik gebruik gemaakt van:
  - Reddit api
    - topics kunnen worden bekeken door .json achter de link naar de subreddit te plaatsen
    - populaire subreddits: https://www.reddit.com/subreddits/popular.json
  - Customtableviewcells om de lijst van subreddits te tonen
  - Core data om de subreddits en topics op te slaan voor offline gebruik (wordt gewist als er wordt vernieuwd)
  - Webview om de html data te tonen of de url

