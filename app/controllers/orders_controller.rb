class OrdersController < ApplicationController
      def index
            @orders = Order.all
            @current_session = request.session_options[:id]

            @cart_orders = Hash.new
            @grand_total = 0

            decoded_order = cookies[:cart].gsub "-", ","
            decoded_order = decoded_order.gsub "/", ""
            decoded_order = JSON.parse(decoded_order)


            decoded_order.each do |key, value|
                  variation_number = key.length / 7
                  if variation_number == 1
                        current_search = Product.find_by("sku": key)
                        @cart_orders[key.to_sym] = Hash.new
                        @cart_orders[key.to_sym]["current_order_name"] = current_search[:name]
                        @cart_orders[key.to_sym]["current_order_quantity"] = value
                        @cart_orders[key.to_sym]["current_order_unit_price"] = current_search[:price]
                        @cart_orders[key.to_sym]["current_order_total"] = @cart_orders[key.to_sym]["current_order_unit_price"] *  @cart_orders[key.to_sym]["current_order_quantity"]
                        @grand_total = @grand_total + @cart_orders[key.to_sym]["current_order_total"]
                  else
                        current_search = Product.find_by("sku": key[0..6])
                        @cart_orders[key.to_sym] = Hash.new
                        @cart_orders[key.to_sym]["current_order_name"] = current_search[:name]
                        @cart_orders[key.to_sym]["current_order_quantity"] = value
                        @cart_orders[key.to_sym]["current_order_unit_price"] = current_search[:price]

                        i = 1
                        while i < variation_number do
                              current_search = Variation.find_by("sku": key[0 + (i * 7)..6 + (i * 7)])
                              @cart_orders[key.to_sym]["current_order_name"] = @cart_orders[key.to_sym]["current_order_name"] + current_search[:name]
                              @cart_orders[key.to_sym]["current_order_unit_price"] = @cart_orders[key.to_sym]["current_order_unit_price"] + current_search[:price]
                              @cart_orders[key.to_sym]["current_order_total"] = @cart_orders[key.to_sym]["current_order_unit_price"] * @cart_orders[key.to_sym]["current_order_quantity"]
                              @grand_total = @grand_total + @cart_orders[key.to_sym]["current_order_total"]

                              i += 1
                        end

                  end


            end

            

      end
    
      def show
      end
    
      def new
      end
    
      def edit
      end
    
      def create
            old_order = Order.find_by user_id: order_params[:user_id], product_id: order_params[:product_id], variation_id: order_params[:variation_id], payment_status: "In Cart"
            
            if old_order != nil
                  old_order.quantity = order.quantity += 1
                  old_order.save
            else
                  @order = Order.new(order_params)
                  @order.save
            end
      end
    
      def update
      end
    
      def destroy
            @order = Order.find(params[:id])

            @order.update(payment_status: "Removed from cart")
            redirect_to orders_path
      end

      private
      def order_params
            params.require(:order).permit(:number, :user_id, :product_id, :quantity, :price, :payment_status, :is_complete, :variation_id)
      end


end
