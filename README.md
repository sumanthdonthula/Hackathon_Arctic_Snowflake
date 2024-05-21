# Hackathon_Arctic_Snowflake

# Project Summary

File: 'bronco.pdf' we should place this in external stage created as part of the file 'preprocess and vectorize bronoc manual.sql'

The content of manual is read page by page and stored in table "page_content_bronco"

Then the page content is transformed into vectors using: SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m', "content") as vector_embeddings

This is saved in table "BRONCO_PAGE_CONTENT_WITH_VECT_EMB"

The when we get query from streamlit app Cosine Similarity is used to filter pages from the cevtor embeddings of pages and top 7 pages are picked as context to pass through arctic model.

function VECTOR_COSINE_SIMILARITY(vector_embeddings,SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m','{query}')) is being used to do this.

once this is done context is passed to Arctic through,
SELECT SNOWFLAKE.CORTEX.COMPLETE('snowflake-arctic','{final_prompt}

The response generated is being summarized using function,
SELECT SNOWFLAKE.CORTEX.SUMMARIZE('{data}')

# Steps to follow to replicate the app

Use Accountadmin as role for all the tasks

Step 1:
run file preprocess and vectorize bronco manual.sql until step-1

Step 2:
place bronco.pdf 
from link: https://drive.google.com/file/d/14HOleVlBVlsQMKI_ClqqKEntZEap_UeM/view?usp=sharing
in external_stage in Data->HACKATHON.PUBLIC ->Stages-> EXTERNAL_STAGE-> bronco.pdf

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

# Prompts

How to turn the headlights on?
How to change the oil?
Im at 65,000 miles, is there any upcoming maintenance?
