# load libraries
library(httr)
library(rtweet)
library(jsonlite)
library(digest)
library(urlshorteneR)

# Create Twitter token
findsbot_token <- rtweet::create_token(
  app = "objectbot",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

search <- paste0('https://cstm-artefacts.vercel.app/cstm.json?sql=SELECT+*+FROM+artefacts+WHERE+NOT+GeneralDescription+IS+NULL+AND+NOT+thumbnail+IS+NULL+ORDER+BY+RANDOM%28%29+LIMIT+1%3B')
randomFinds <- fromJSON(search)
df <- as.data.frame(randomFinds$rows)
artifactNumber <- df$V1
generalDescription <- df$V3
contextFunction <- df$V17
thumbnail <- df$V36

liveLink <- paste0('https://ingeniumcanada.org/ingenium/collection-research/collection-item.php?id=', artifactNumber)
shortlink <- vgd_LinksShorten(longUrl = liveLink)

tweet <- paste(artifactNumber,generalDescription,contextFunction,shortlink, sep=' ')

image <- paste0(artifactNumber,'.aa.cs.thumb.png')
imageUrl <- paste0('http://source.techno-science.ca/artifacts-artefacts/images/', URLencode(image))
#if http_error is true, then the image URL is broken
if (http_error(imageUrl)){
  imageUrl <- paste0('https://ingeniumcanada.org/sites/default/files/styles/inline_image/public/2018-04/lighthouse_.jpg')
  tweet <- paste(artifactNumber,generalDescription,contextFunction, "no image available", sep=' ')
}

temp_file <- tempfile()
download.file(imageUrl, temp_file)

# post the tweet
rtweet::post_tweet(
  status = tweet,
  media = temp_file,
  token = findsbot_token
)
