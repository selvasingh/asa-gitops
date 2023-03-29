# Blue green deployment rules

## set the version of the staging deployment

When a new version of the code is to be released, edit the non production file.
If green is in production edit the blue file, if blue is in production edit 
the green file so that the new version of the code is deployed to a non 
production deployment.

When you change the blue or green file a workflow will kick in to do an
`az spring apps deploy` to the deployment withe the name that matches the filename.
if you edit the blue file the workfow will deploy the code to the blue version
... etc.

## switch the production deployment 

edit the produciton file to set the name of the deployment that should be
the production one. When the production file is edited a workfolw kicks in 
to set the production deployment using the `az spring app set-deployment` 
command or action equivalent.

## if you don't to skip blue green deployment

In case you don't want to do blue-green deployment you should delete the blue
file and set the production file to point to green as the production deployment.
then edit the green file with new versions of the app.