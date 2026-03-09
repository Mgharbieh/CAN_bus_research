from langchain_ollama import ChatOllama as ai

llm = ai(model="llama3")
print(llm.invoke("Write me a haiku.").content)
