class FunctionController < ApplicationController

	def show
	
		datas = insert_expenses_functions(2015,2015,1,12,1,31)
		ordered_data = datas.sort_by {|description,sumValue| -sumValue}
		@correct_datas = datas.to_json	
		@top_10_data = filter_top_n(ordered_data, 10).
		sort_by {|description,sumValue| description}.to_h.to_json
		puts @top_10_data
	end

	def filter

		@correct_datas = []
		datas = control_datas(params[:year],params[:month])
		@correct_datas = datas.to_json
		render 'show'

	end

	def filter_top_n(hash,n)
		
		new_hash = {}

		hash.each_with_index do |(description,sumValue),index| 

			if (index >= n)
				break
			end
			new_hash[description] = sumValue
		end 
		return new_hash
	end

	def control_datas(year = "Todos",month = "Todos")

		if year == "Todos"
			insert_expenses_functions(2010,2015,1,12,1,31)
		elsif year == "Até hoje!"
			insert_expenses_functions(2010,2015,1,12,1,31)
		else	
			if month == "Todos"
				insert_expenses_functions(year.to_i,year.to_i,1,12,1,31)
			else
				day_final = find_month_limit(month_to_int(month))
				day_init = 1
				insert_expenses_functions(year.to_i,year.to_i,month_to_int(month),month_to_int(month),day_init,day_final)
			end
		end

	end

	def insert_expenses_functions(year_init,year_final,month_init,month_final,day_init,day_final)

		
		expenses = get_expenses_by_function(year_init,year_final,month_init,month_final,day_init,day_final)
		expense_hash = convert_to_a_hash(expenses)
		correct_datas = filter_datas_in_expense(expense_hash)
		
	end
	def get_expenses_by_function(first_year,last_year,first_month,last_month,first_day,last_day)

		start = Date.new(first_year,first_month,first_day)
		end_of = Date.new(last_year,last_month,last_day)

  		Function.joins(:expense).where("DATE(payment_date) BETWEEN ? AND ?", start, end_of).select("YEAR(payment_date) as date_test,sum(expenses.value) as sumValue,functions.description").group("YEAR(payment_date),functions.description").to_json

	end

	def convert_to_a_hash(expenses)

		expense_hash = JSON.parse(expenses)
		
	end

	def filter_datas_in_expense(expense_hash)

  		correct_hash = {}
  		expense_hash.each do |hash|
    		correct_hash[hash["description"]] = hash["sumValue"]    
  		end
  		return correct_hash
	end

	def find_month_limit(month)
		if month == 1 or  month == 3 or month == 5 or month ==  7 or month == 8 or  month == 10 or month == 12
			return 31
		elsif month == 4 or  month == 6 or month == 9 or month == 11
			return 30
		elsif month == 2
			return 28 
		end
	end

end	