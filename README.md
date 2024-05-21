# Hackathon_Arctic_Snowflake

Use Accountadmin as role for all the tasks

Step 1:
run file preprocess and vectorize bronco manual.sql until step-1

Step 2:
place bronco.pdf in external_stage in Data->HACKATHON.PUBLIC ->Stages-> EXTERNAL_STAGE-> bronco.pdf

Step 3:
run After Step-2

Step-4:
Create a Streamlit app from worksheet snowflake new app and name it as 'KNOW_YOUR_VEHICLE'
and copy script from Streamlit Files->streamlit_app.py and save the app.

Step-5:
Place, pandata-logo.PNG from Streamlit Files->pandata-logo.PNG into the folder where staging for streamlit_app is there. Data->HACKATHON.PUBLIC -> Stages -> "Stage Created for Streamlit App"-> pandata-logo.PNG

Step-6:
Copy Streamlit Files->environment.yml file into the folder where staging for streamlit_app is there. Data->HACKATHON.PUBLIC -> Stages -> "Stage Created for Streamlit App"-> environment.yml

Once the steps are followed, we should be able to get the responses for the queries we have given to the streamlit app by using Arctic and the Context from the Manual->bronco.pdf.
