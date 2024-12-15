import os

class Config:
    SQLALCHEMY_DATABASE_URI = (
        'mssql+pyodbc://tudor:ParolaSigura123!@localhost/Proiect?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes'
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False
