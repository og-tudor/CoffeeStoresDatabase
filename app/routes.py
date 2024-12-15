import plotly.graph_objs as go
from flask import render_template, current_app
from sqlalchemy.sql import text
from . import db

@current_app.route('/')
def dashboard():
    # Execută query-ul pentru datele necesare
    query = text("""
        SELECT p.name AS product_name, SUM(od.quantity) AS total_quantity
        FROM Products p
        JOIN OrderDetails od ON p.product_id = od.product_id
        GROUP BY p.name
        ORDER BY total_quantity DESC;
    """)
    result = db.session.execute(query)
    data = result.fetchall()

    # Extrage datele
    product_names = [row[0] for row in data]
    quantities = [row[1] for row in data]

    # Creează graficul interactiv folosind Plotly
    fig = go.Figure(
        data=[go.Bar(
            x=product_names,
            y=quantities,
            marker=dict(color='#BE7462'),  # Culoarea coloanelor
            hoverinfo='x+y',
            text=quantities,
            textposition='outside'
        )]
    )

    # Setează background-ul graficului
    fig.update_layout(
        title='Total Quantity Sold per Product',
        xaxis_title='Product Name',
        yaxis_title='Total Quantity',
        xaxis_tickangle=-45,
        template='plotly_dark',
        paper_bgcolor='#514A73',  # Background general
        plot_bgcolor='#514A73',   # Background grafic
        font=dict(color='white')  # Culoarea textului
    )

    # Convertește graficul într-un HTML embeddable
    graph_html = fig.to_html(full_html=False)

    return render_template('index.html', graph_html=graph_html)
