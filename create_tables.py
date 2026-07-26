from app.database.database import engine
from app.models.user import Base

Base.metadata.create_all(bind=engine)

print("Table created!")