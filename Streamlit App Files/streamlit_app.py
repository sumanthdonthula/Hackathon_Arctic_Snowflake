# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.session import Session
from PIL import Image
import re

class QueryGenerator:
    
    def __init__(self, session: Session):
        self.session = session

    def get_answer(self, query):
        
        top_match_page_context=session.sql(f'''SELECT "content" from HACKATHON.PUBLIC.BRONCO_PAGE_CONTENT_WITH_VECT_EMB ORDER BY VECTOR_COSINE_SIMILARITY(vector_embeddings,SNOWFLAKE.CORTEX.EMBED_TEXT_768('snowflake-arctic-embed-m','{query}')) DESC LIMIT 7''')
        context=top_match_page_context.to_pandas().to_string()
        context = re.sub(r'[^a-zA-Z0-9\s]', '', context)
        
        prompt='You are a bot who will get the query from user and give response based on the pages of user manual called context. The context is'
        final_prompt=prompt+context+' Now, answer the query '+query
        response= session.sql(f"SELECT SNOWFLAKE.CORTEX.COMPLETE('snowflake-arctic','{final_prompt}+')")
        return response
    
    def summarize(self, data):
        return self.session.sql(f"SELECT SNOWFLAKE.CORTEX.SUMMARIZE('{data}')")

# Get the current credentials
session = get_active_session()
engine = QueryGenerator(session)


logo = Image.open('/tmp/appRoot/pandata-logo.png')
logo = logo.resize((125, 125))  # Resize the image

manual_location = '/tmp/appRoot/bronco.pdf'

col1, col2 = st.columns(2)
with col1:
    st.image(logo, use_column_width=False)  # Display the image

st.divider()

with st.expander('', True):
    st.subheader('Ford Bronco')
    st.caption('Here is a caption relevant to Ford Bronco stuff')

# Write directly to the app
user_input = st.chat_input('What can I help you understand about your Bronco homie?')

if user_input:
    st.write('Here is your answer!')
    data = engine.get_answer(user_input)
    response_df=data.to_pandas()
    final_response=response_df.to_string(index=False,header=False).encode('utf-8')
    final_response=final_response.decode('unicode_escape')
    
    if data:
        st.divider()
        st.write(final_response)
        final_response = re.sub(r'[^a-zA-Z0-9\s]', '', final_response)
        st.divider()
        st.write('Here is the Summary of above text:')
        summary=engine.summarize(final_response).to_pandas()
        summary=summary.to_string(index=False,header=False)
        st.write(summary)
