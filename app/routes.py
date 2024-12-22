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
        
    @app.route('/api/expenses_by_category', methods=['GET'])
    def expenses_by_category():
        store_id = request.args.get('store_id')
        month = request.args.get('month')
        year = request.args.get('year')
        if not store_id or not month or not year:
            return jsonify({'error': 'store_id, month, and year are required'}), 400
        try:
            query = text("EXECUTE GetMonthlyExpensesByCategory @store_id = :store_id, @month = :month, @year = :year")
            result = db.session.execute(query, {'store_id': store_id, 'month': month, 'year': year}).fetchall()
            data = [{
                'exp_month_year': row[0],
                'store_id': row[1],
                'category': row[2],
                'total': float(row[3]) if row[3] else 0
            } for row in result]
            return jsonify(data)
        except Exception as e:
            return jsonify({'error': str(e)}), 500


    # Route for Employees page
    @app.route('/employees')
    def employees():
        return render_template('employees.html', title="Employees")
    
    @app.route('/api/employees_of_the_month', methods=['GET'])
    def employees_of_the_month():
        query = text("EXEC EmployeesOfTheMonth;")
        result = db.session.execute(query)
        data = [{'employee_name': row[0], 'number__of_orders': row[1], 'store_name': row[2]} for row in result.fetchall()]
        return jsonify(data)
    
    @app.route('/api/employees_eligible_for_promotion', methods=['GET'])
    def employees_eligible_for_promotion():
        store_id = request.args.get('store_id')
        if not store_id:
            return jsonify({'error': 'store_id is required'}), 400
        query = text("EXEC EmployeesEligibleForPromotion @store_id = :store_id")
        result = db.session.execute(query, {'store_id': store_id})
        data = [{'number_of_orders': row[0], 'employee_name': row[1], 'store_name': row[2]} for row in result.fetchall()]
        return jsonify(data)

    @app.route('/api/underperforming_managers', methods=['GET'])
    def underperforming_managers():
        store_id = request.args.get('store_id')
        if not store_id:
            return jsonify({'error': 'store_id is required'}), 400
        query = text("EXEC GetUnderperformingManagers @store_id = :store_id")
        result = db.session.execute(query, {'store_id': store_id})
        data = [{'manager_name': row[0], 'store_name': row[1], 'manager_salary': row[2], 'max_employee_salary': row[3], 'revenue_goal': row[4]} for row in result.fetchall()]
        return jsonify(data)
    
    @app.route('/api/upcoming_birthdays', methods=['GET'])
    def get_upcoming_birthdays():
        query = text("EXEC GetUpcomingBirthdays")
        result = db.session.execute(query)
        data = [{'employee_name': row[0], 'birth_date': row[1]} for row in result.fetchall()]
        return jsonify(data)

    # Route for Products page
    @app.route('/products')
    def products():
        return render_template('products.html', title="Products")
    
    @app.route('/api/products_list', methods=['GET'])
    def products_list():
        query = text("EXEC GetAllProducts")
        result = db.session.execute(query)
        data = [{'id': row[0], 'name': row[1]} for row in result.fetchall()]
        return jsonify(data)
    
    @app.route('/api/low_stock_products', methods=['GET'])
    def low_stock_products():
        store_id = request.args.get('store_id')
        quantity = request.args.get('quantity')
        if not store_id or not quantity:
            return jsonify({'error': 'store_id and quantity are required'}), 400
        query = text("EXEC GetLowStockProducts @store_id = :store_id, @quantity = :quantity")
        result = db.session.execute(query, {'store_id': store_id, 'quantity': quantity})
        data = [{'id': row[0], 'name': row[1], 'unit_price': row[2], 'quantity': row[3], 'company_name': row[4]} for row in result.fetchall()]
        return jsonify(data)
    
    @app.route('/api/max_stock', methods=['GET'])
    def max_stock():
        store_id = request.args.get('store_id')
        if not store_id:
            return jsonify({'error': 'store_id is required'}), 400
        query = text("EXEC GetMaxStockProducts @store_id = :store_id")
        result = db.session.execute(query, {'store_id': store_id})
        data = [{'max_stock': row[0]} for row in result.fetchall()]
        return jsonify(data)

    @app.route('/api/best_selling_products_last_month', methods=['GET'])
    def best_selling_products_last_month():
        store_id = request.args.get('store_id')
        if not store_id:
            return jsonify({'error': 'store_id is required'}), 400
        query = text("EXEC GetBestSellingProductsLastMonth @store_id = :store_id")
        result = db.session.execute(query, {'store_id': store_id})
        data = [{'product_name': row[0], 'quantity_sold': row[1], 'period': row[2]} for row in result.fetchall()]
        return jsonify(data)
    
    @app.route('/api/profit_per_category', methods=['GET'])
    def profit_per_category():
        store_id = request.args.get('store_id')
        if not store_id:
            return jsonify({'error': 'store_id is required'}), 400
        query = text("EXEC GetProfitPerCategory @store_id = :store_id")
        result = db.session.execute(query, {'store_id': store_id})
        data = [{'category': row[0], 'total_quantity_sold': row[1], 'total_profit': row[2], 'period': row[3]} for row in result.fetchall()]
        return jsonify(data)
    
    @app.route('/api/product_sales_evolution', methods=['GET'])
    def product_sales_evolution():
        store_id = request.args.get('store_id')
        product_id = request.args.get('product_id')
        if not store_id or not product_id:
            return jsonify({'error': 'store_id and product_id are required'}), 400
        query = text("EXEC GetSalesEvolutionPerProduct @store_id = :store_id, @product_id = :product_id")
        result = db.session.execute(query, {'store_id': store_id, 'product_id': product_id})
        data = [{'product_id': row[0], 'product_name': row[1], 'sales_month_year': row[2], 'quantity_sold': row[3]} for row in result.fetchall()]
        return jsonify(data)