import os

class Config:
    DB_USERNAME = 'tudor'
    DB_PASSWORD = 'ParolaSigura123!'
    DB_HOST = 'localhost'
    DB_NAME = 'Proiect'
    DB_DRIVER = 'ODBC+Driver+17+for+SQL+Server'
    
    # string ul necesar conexiunii la baza de date
    SQLALCHEMY_DATABASE_URI = (
        f'mssql+pyodbc://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}?driver={DB_DRIVER}&TrustServerCertificate=yes'
    )