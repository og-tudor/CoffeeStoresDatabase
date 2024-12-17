from flask import jsonify, render_template, request
from sqlalchemy.sql import text
from . import db

def register_routes(app):
    # Route for index page
    @app.route('/')
    def index():
        return render_template('index.html')

    # Route for Coffee Stores page
    @app.route('/coffee_stores')
    def coffee_stores():
        return render_template('coffee_stores.html', title="Coffee Stores")

    # Route for Employees page
    @app.route('/employees')
    def employees():
        return render_template('employees.html', title="Employees")

    # Route for Products page
    @app.route('/products')
    def products():
        return render_template('products.html', title="Products")


    @app.route('/api/coffee_stores_list', methods=['GET'])
    def coffee_stores_list():
        query = text("EXECUTE GetCoffeeStores;")
        result = db.session.execute(query)
        data = [{'id': row[0], 'name': row[1]} for row in result.fetchall()]
        return jsonify(data)


    @app.route('/api/coffee_store_details/<int:store_id>', methods=['GET'])
    def coffee_store_details(store_id):
        query = text("EXEC GetCoffeeStoreDetails @store_id = :store_id")
        result = db.session.execute(query, {'store_id': store_id}).fetchone()

        if result:
            data = {
                'name': result[0],
                'city': result[1],
                'address': result[2],
                'manager': result[3],
                'revenue_goal': result[4] if result[4] else "No data",
                'total_revenue': result[5] if result[5] else 0,
            }
            return jsonify(data)
        else:
            return jsonify({'error': 'Store not found'}), 404

    @app.route('/api/monthly_sales_expenses', methods=['GET'])
    def monthly_sales_expenses():
        # Get parameters from query string
        store_id = request.args.get('store_id')
        year = request.args.get('year')

        # Validate inputs
        if not store_id or not year:
            return jsonify({'error': 'store_id and year are required'}), 400

        try:
            # Execute the procedure with parameters
            query = text("""
                EXEC GetMonthlySalesAndExpenses @store_id = :store_id, @year = :year
            """)
            result = db.session.execute(query, {'store_id': store_id, 'year': year}).fetchall()

            # Process the data into a JSON response
            data = [{
                'store_name': row[0],
                'month': row[1],
                'year': row[2],
                'monthly_revenue': float(row[3]) if row[3] else 0,
                'monthly_expenses': float(row[4]) if row[4] else 0
            } for row in result]

            return jsonify(data)

        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/registered_unregistered_customers', methods=['GET'])
    def registered_unregistered_customers():
        store_id = request.args.get('store_id')
        if not store_id:
            return jsonify({'error': 'store_id is required'}), 400

        try:
            # Execută procedura stocată cu parametru
            query = text("EXEC GetRegisteredANDUnregisteredCustomers @store_id = :store_id")
            result = db.session.execute(query, {'store_id': store_id}).fetchone()

            # Verificăm dacă există rezultate
            if result:
                data = {
                    'registered_customers': result[1],
                    'unregistered_customers': result[2]
                }
                return jsonify(data)
            else:
                return jsonify({'error': 'No data found for the specified store_id'}), 404

        except Exception as e:
            return jsonify({'error': str(e)}), 500
