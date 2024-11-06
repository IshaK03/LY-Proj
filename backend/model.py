# Import necessary libraries
import csv
import os
import warnings
import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from dotenv import load_dotenv
from langchain_community.document_loaders import CSVLoader
from langchain.docstore.document import Document

# Configure environment and load variables
warnings.filterwarnings("ignore")
load_dotenv(".env")

# Configure API key
GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')
genai.configure(api_key=GOOGLE_API_KEY)

# Initialize model and embeddings
model = ChatGoogleGenerativeAI(model="gemini-pro", google_api_key=GOOGLE_API_KEY, temperature=0.7, convert_system_message_to_human=True)
embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001", google_api_key=GOOGLE_API_KEY)

# Initialize Chroma database
chroma_db = Chroma(persist_directory="data", embedding_function=embeddings, collection_name="lc_chroma_demo")

# Clear existing collection if any
collection = chroma_db.get()['ids']
if len(collection):
    chroma_db.delete(ids=collection)

# Load CSV data
def load_csv(file_path: str):
    documents = []
    try:
        with open(file_path, 'r') as file:
            reader = csv.reader(file)
            for row in reader:
                documents.append({"text": ' '.join(row)})
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    return documents

# Update the database with documents from CSV files
def update_db():
    global chroma_db
    docs = []

    # Load predefined CSV files
    csv_files = [
        "./files/dataset.csv",
        "./files/symptom_Description.csv",
        "./files/symptom_precaution.csv",
        "./files/Symptom-severity.csv"
    ]

    for csv_file in csv_files:
        csv_data = load_csv(csv_file)
        if csv_data:
            print(f"Loaded data from {csv_file}")
        else:
            print(f"No data found in {csv_file}")
        # Create Document objects for CSV data, using 'text' key
        csv_docs = [Document(page_content=item['text']) for item in csv_data]
        docs.extend(csv_docs)

    # Persist the updated database
    if docs:
        chroma_db = Chroma.from_documents(documents=docs, embedding=embeddings, persist_directory="data", collection_name="lc_chroma_demo")
        chroma_db.persist()
        print("Database updated successfully.")
    else:
        print("No documents were loaded to update the database.")

# Query processing
# Query processing with persistent retriever initialization
def run_query(query: str):
    if len(chroma_db.get()['ids']) == 0:
        return "The vector database is currently empty. Please add relevant documents to perform a search."

    # Reload retriever to ensure connection persists for every query
    retriever = chroma_db.as_retriever()

    # Improved prompt template
    template = """
    You are a helpful interactive chatbot.
    If it is a casual conversation, respond accordingly.
    You are a highly knowledgeable medical assistant chatbot. Use the following pieces of document to answer the question at the end, emphasizing any details provided in CSV files first. If no relevant information is found, respond based on general knowledge or available documents.
    Context: {context}
    Question: {question}
    Answer in a helpful, medically accurate way:"""
    QA_CHAIN_PROMPT = PromptTemplate.from_template(template)

    qa_chain = RetrievalQA.from_chain_type(
        model,
        chain_type="stuff",
        retriever=retriever,
        return_source_documents=True,
        chain_type_kwargs={"prompt": QA_CHAIN_PROMPT}
    )

    # Run the query and return result
    result = qa_chain({"query": query})
    return result["result"]

# Initialize and update the database
update_db()

# Interactive loop for querying in the terminal
# def main():
#     print("RAG Chatbot is ready! Type your questions below (type 'exit' to quit):")
#     while True:
#         query = input("You: ")
#         if query.lower() == 'exit':
#             print("Chatbot session ended.")
#             break
#         response = run_query(query)
#         print(f"Chatbot: {response}\n")

# if __name__ == "__main__":
#     main()
