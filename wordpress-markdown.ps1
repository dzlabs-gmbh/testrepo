$user = ''
$pass = ''

$pair = "$($user):$($pass)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}



# Get Posts / https://developer.wordpress.org/rest-api/using-the-rest-api/pagination/
# $posts_draft = Invoke-WebRequest -Uri 'http://wordpress/wp-json/wp/v2/posts?status=draft' -Headers $Headers

#$posts = Invoke-WebRequest -Uri 'http://wordpress/wp-json/wp/v2/posts?status=draft' -Headers $Headers
1..5 |%{
$uri_posts = "http://wordpress/wp-json/wp/v2/posts?per_page=100&page=" + $_
$posts = Invoke-WebRequest -Uri $uri_posts -Headers $Headers
$json_posts = $json_posts + ($posts.content | convertfrom-json)
}

1..15 |%{
$uri_media = "http://wordpress/wp-json/wp/v2/media?per_page=100&page=" + $_
$media = Invoke-WebRequest -Uri $uri_media -Headers $Headers
$json_media = $json_media + ($media.content | convertfrom-json)
}
$media_hashtable = @{}
$json_media | Foreach { $media_hashtable[$_.source_url.replace('http://wordpress','').trim('"')] = $_.id }

$categories = Invoke-WebRequest -Uri 'http://wordpress/wp-json/wp/v2/categories' -Headers $Headers
$tags = Invoke-WebRequest -Uri 'http://wordpress/wp-json/wp/v2/tags?per_page=100&page=1' -Headers $Headers

# Convert json
# $json_posts = $posts.content | convertfrom-json
# $json_media = $media.content | convertfrom-json
$json_categories = $categories.content | convertfrom-json

$tags_hashtable = @{}
$json_tags = $tags.content | convertfrom-json
$json_tags | Foreach { $tags_hashtable[$_.Name] = $_.id }

# Change Date or Tag
#foreach ($post in $json_posts) {
#    $postfile = $post.link.split("/blog/")[-1].trim("/")
#	$post.id
#	$file_meta = get-content -Path "\blog\$postfile.md" -first 8 | ?{$_ -like "*:*"} | ConvertFrom-StringData -Delimiter ":"
#	if ($file_meta) {
#	$meta_date = $file_meta.date.trim('"').split("-")
#	$post_date = Get-Date -Year $meta_date[0] -Month  $meta_date[1] -Day  $meta_date[2]
#	
#	if ($file_meta.tags) {
#	$post_tags = $file_meta.tags | convertfrom-json
#	foreach ($i in $post_tags) {
#		$post_tags = $post_tags -replace $i, $tags_hashtable[$i]
#		}
#	}

# Change Category based on tag
# foreach ($post in $json_posts_by_tag_cncloud) {
 
	#$body = @{
    #"date" = $post_date
	#"status" = "publish"
	#"tags" = (([System.Int32[]]$post_tags) -ne "")
	#"categories" = 30
    #}
	#Invoke-WebRequest -Method 'Post' -Uri http://wordpress/wp-json/wp/v2/posts/$($post.id) -Body ($body|ConvertTo-Json) -Headers $headers -ContentType "application/json"
	#}


# Change preview image
foreach ($post in $json_posts) {
    $postfile = $post.link.split("/blog/")[-1].trim("/")
	$post.id
	$file_meta = get-content -Path "blog\$postfile.md" -first 8 | ?{$_ -like "*:*"} | ConvertFrom-StringData -Delimiter ":"
	$meta_image = ($file_meta.image).trim('"') 
	
	if ($meta_image) {
		$post_image = $media_hashtable[$meta_image]	
	    $body = @{
	      "featured_media" = $([System.Int32[]]$post_image)
        }
	    Invoke-WebRequest -Method 'Post' -Uri http://wordpress/wp-json/wp/v2/posts/$($post.id) -Body ($body|ConvertTo-Json) -Headers $headers -ContentType "application/json"
	}
}


# foreach ($post in $json_posts_by_tag_cncloud) {
 
