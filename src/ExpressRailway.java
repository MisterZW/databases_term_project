package src;

import java.util.*;
import java.io.*;
import java.sql.*;
import java.sql.SQLException;

public class ExpressRailway {

	public final static int ZIP_LENGTH = 5;
	public final static int PHONE_NUMBER_LENGTH = 10;
	public final static int PAGINATION_CONSTANT = 10;
	public final static String sort_menu = 	"---- SORTING OPTIONS ----\n" +
											"1 -- Number of Stops\n" +
											"2 -- Number of Stations Passed\n" +
											"3 -- Total Price\n" +
											"4 -- Total Time\n" +
											"5 -- Total Distance";

	public final static String[] tableNames = {
		"AGENT",
		"RAIL_LINE",
		"PASSENGER",
		"TRAIN",
		"STATION",
		"TRAIN_ROUTE",
		"CONNECTION",
		"ROUTE_STATIONS",
		"SCHEDULE",
		"TRIP",
		"BOOKING"
	};

	private Connection conn;
	private Properties props;
	private static Scanner scan;
	private ScriptRunner runner;

	public ExpressRailway() {

		try {
			Class.forName("org.postgresql.Driver");
			String url = "jdbc:postgresql://localhost/zdw9";

			props = new Properties();
			props.setProperty("user","zdw9");
			props.setProperty("password","example");

			conn = DriverManager.getConnection(url, props);

			//autoCommit = false, stopOnError = true
			runner = new ScriptRunner(conn, false, true);
		}
		catch (ClassNotFoundException cnfe) {
			System.out.println("Could not load the postgresql driver.\n" + 
				"Try running the command 'make run' from the main directory.");
			System.exit(1);
		}
		catch (SQLException e) {
			handleSQLException(e);
			System.exit(2);
		}

		UIMenu();
	}


	/* 
	* main user interface @ the command line
	* runs as a loop which pauses for confirmation after successful operations
	*/
	public void UIMenu(){
		scan = new Scanner(System.in);		

		String menu = "--------Welcome to Express Railway---------\n\n"
					+ "\t1. Add a new customer account\n"
					+ "\t2. Edit a customer account\n"
					+ "\t3. View customer account information\n"
					+ "\t4. Single Route Trip Search\n"
					+ "\t5. Combination Route Trip Search\n"
					+ "\t6. Add Reservation for a Single Route\n"
					+ "\t7. Add Reservation for a Sequence of Trips\n"
					+ "\t8. Find trains which pass through a specific station at a given time\n"
					+ "\t9. Find routes which travel more than one rail line\n"
					+ "\t10. Find routes which pass through the same stations but have different stops\n"
					+ "\t11. Find stations that all trains pass through\n"
					+ "\t12. Find all trains that do not stop at a specific station\n"
					+ "\t13. Find routes that stop at at least a specified percentage of stations\n"
					+ "\t14. Display the schedule of a route\n"
					+ "\t15. Find the availability of a route at every stop on a specific day\n"
					+ "\t16. Import Database\n"
					+ "\t17. Export Database\n"
					+ "\t18. Delete Database\n"
					+ "\t19. Exit\n";
		
		while(true) {
			System.out.println(menu);
			System.out.print("Enter your choice: ");
			String input = scan.nextLine();
			
			switch(input) {
			case "1":
				addNewCustomer();
				break;
			case "2":
				editCustomer();
				break;
			case "3":
				viewCustomer();
				break;
			case "4":
				singleTripRouteSearch();
				break;
			case "5":
				comboTripRouteSearch();
				break;
			case "6":
				addReservation("agent1");
				break;
			case "7":
				addTripBookings("agent1");
				break;
			case "8":
				trainsThruStation();
				break;
			case "9":
				moreThanOneRail();
				break;
			case "10":
				sameStationsDiffStops();
				break;
			case "11":
				stationsAllTrainsPassThrough();
				break;
			case "12":
				trainsWhichDontGoHere();
				break;
			case "13":
				greaterThanPercentStops();
				break;
			case "14":
				getRouteSchedule();
				break;
			case "15":
				findRouteAvailability();
				break;
			case "16":
				importDatabase();
				break;
			case "17":
				exportDatabase();
				break;
			case "18":
				dropDatabase();
				break;
			case "19":
				scan.close();
				System.exit(0);
				break;
			default:
				System.out.println("Invalid option selected.");
				continue;
			}
			confirmContinue();
		}
		
	}


	public static void main(String args[]) {
		new ExpressRailway();
	}


	/* Confirm user wants to continue operations to avoid spamming menu after displaying results */
	public void confirmContinue() {
		System.out.println("--- Press enter to return to the menu ---");
		scan.nextLine();
	}


	/*
	* Insert a new customer in to the system
	# Prints the new customer ID if successful
	*/
	public boolean addNewCustomer() {
		System.out.println("----Add a new customer account----");

		String fname = getStringFromUser("Enter the customer's first name: ");
		String lname = getStringFromUser("Enter the customer's last name: ");
		String email = getStringFromUser("Enter the customer's email address: ");
		String phone = getNlengthString("Enter the customer's phone number (Format ##########): ", PHONE_NUMBER_LENGTH);
		String street_addr = getStringFromUser("Enter the customer's street address: ");
		String city = getStringFromUser("Enter the customer's city: ");
		String zip = getNlengthString("Enter the customer's ZIP code (Format #####): ", ZIP_LENGTH);

		try {
			PreparedStatement ps = conn.prepareStatement(
					"SELECT * FROM create_customer_account(?, ?, ?, ?, ?, ?, ?);");
			ps.setString(1, fname);
			ps.setString(2, lname);
			ps.setString(3, email);
			ps.setString(4, phone);
			ps.setString(5, street_addr);
			ps.setString(6, city);
			ps.setString(7, zip);
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				int newCustomerId = rs.getInt(1);
				System.out.printf("Success! %s's new ID # is %d\n", fname, newCustomerId);
			}
			else {
				System.out.println("Sorry, there was a problem entering that user into the database.");
			}
			return true;
		}
		catch (SQLException e) {
			handleSQLException(e);
			System.out.println("Sorry, there was a problem entering that user into the database.");
		}
		return false;
	}


	/*
	* Edit an existing customer's data in the database
	* Prints the current data associated with that customer for reference
	* Then, prompts for new data to populate ALL fields except customer ID for simplicity
	*/
	public boolean editCustomer() {
		System.out.println("----Edit a customer account----");
		int cust_id = getIntFromUser("Enter the customer ID for the record you wish to edit: ", 1, Integer.MAX_VALUE);

		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM view_customer_account(%d);", cust_id);
			ResultSet rs1 = st.executeQuery(query);
			System.out.println("----Here is the current record for Passenger " + cust_id + "----");
			printResultSet(rs1);
			System.out.println("----Please enter the new information for Passenger " + cust_id + "----");
			String fname = getStringFromUser("Enter the customer's first name: ");
			String lname = getStringFromUser("Enter the customer's last name: ");
			String email = getStringFromUser("Enter the customer's email address: ");
			String phone = getNlengthString("Enter the customer's phone number (Format ##########): ", PHONE_NUMBER_LENGTH);
			String street_addr = getStringFromUser("Enter the customer's street address: ");
			String city = getStringFromUser("Enter the customer's city: ");
			String zip = getNlengthString("Enter the customer's ZIP code (Format #####): ", ZIP_LENGTH);

		
			PreparedStatement ps = conn.prepareStatement(
					"SELECT * FROM update_customer_account(?, ?, ?, ?, ?, ?, ?, ?);");
			ps.setInt(1, cust_id);
			ps.setString(2, fname);
			ps.setString(3, lname);
			ps.setString(4, email);
			ps.setString(5, phone);
			ps.setString(6, street_addr);
			ps.setString(7, city);
			ps.setString(8, zip);
			ResultSet rs2 = ps.executeQuery();
			System.out.printf("Customer ID %d's data has been updated successfully.\n", cust_id);
			return true;
		}
		catch (SQLException e) {
			handleSQLException(e);
			System.out.println("Sorry, there was a problem updating the user's information in the database.");
		}
		return false;
	}


	/*
	* View customer data associated with a given customer's ID # in the database
	*/
	public void viewCustomer() {
		System.out.println("----View customer account information----");
		int cust_id = getIntFromUser("Enter the customer's ID number: ", 1, Integer.MAX_VALUE);
		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM view_customer_account(%d);", cust_id);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/*******************************************************************************************
	* Find all routes that stop at a specified arrival station and then at the specified
	* destination station on a specified day of the week
	*
	* excludes trip results which have no available seats
	*******************************************************************************************/
	public void singleTripRouteSearch() {
		System.out.println("----Single Route Trip Search----");
		int arrival_station = getIntFromUser("Enter the arrival station ID #: ", 1, Integer.MAX_VALUE);
		int destination_station = getIntFromUser("Enter the destination station ID #: ", 1, Integer.MAX_VALUE);
		int target_day = getIntFromUser("Enter the travel day: ", 1, 7);

		System.out.println(sort_menu);
		int sort_option = getIntFromUser("How would you like to sort your results? --> ", 1, 5);
		boolean sort_asc = getBooleanFromUser("Would you like to sort from lowest to highest? (Y / N) --> ");

		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM sort_STRS(%d, %s, %d, %d, %d);",
				 sort_option, Boolean.toString(sort_asc), arrival_station, destination_station, target_day);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/******************************************************************************************
	* Combinatory search function: Find all route combinations that stop
	* at the specified Arrival Station and then at the specified Destination
	* Station on a specified day of the week.
	*
	* Returns a table of integer arrays representing possible combinations of trip IDs
	* which link source to sink in the graph (taking into account day and seats available)
	*
	* Also returns desciptive statistics about the route which is used to sort results
	******************************************************************************************/
	public void comboTripRouteSearch() {
		System.out.println("----Combination Route Trip Search----");
		int arrival_station = getIntFromUser("Enter the arrival station ID #: ", 1, Integer.MAX_VALUE);
		int destination_station = getIntFromUser("Enter the destination station ID #: ", 1, Integer.MAX_VALUE);
		int target_day = getIntFromUser("Enter the travel day: ", 1, 7);

		System.out.println(sort_menu);
		int sort_option = getIntFromUser("How would you like to sort your results? --> ", 1, 5);
		boolean sort_asc = getBooleanFromUser("Would you like to sort from lowest to highest? (Y / N) --> ");

		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM sort_CTRS(%d, %s, %d, %d, %d);",
				 sort_option, Boolean.toString(sort_asc), arrival_station, destination_station, target_day);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/*****************************************************************************************
	* Make a reservation for all trips between arr_station and dest_station on a schedule
	* Makes reservation as a transaction, so all bookings will fail if any one booking fails
	*
	* @param username -- The agent making the booking
    *****************************************************************************************/
	public void addReservation(String username) {
		System.out.println("----Add Reservation for a Single Route----");
		int passenger_id = getIntFromUser("For which passenger ID # would you like to book a reservation? --> ", 1, Integer.MAX_VALUE);
		int target_schedule = getIntFromUser("For which schedule ID # would you like to book a reservation? --> ", 1, Integer.MAX_VALUE);
		int num_tickets = getIntFromUser("How many tickets would you like to reserve? --> : ", 1, Integer.MAX_VALUE);
		int arrival_station = getIntFromUser("Enter the arrival station ID #: ", 1, Integer.MAX_VALUE);
		int destination_station = getIntFromUser("Enter the destination station ID #: ", 1, Integer.MAX_VALUE);

		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT make_reservation('%s', %d, %d, %d, %d, %d);",
				 username, passenger_id, target_schedule, num_tickets, arrival_station, destination_station);
			st.executeQuery(query);
			System.out.println( String.format("Reserved %d tickets for passenger %d on schedule %d between stations %d and %d",
				num_tickets, passenger_id, target_schedule, arrival_station, destination_station) );
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/*******************************************************************************************
	* Make a reservation for all trips ids specified by the user (e.g., from a CTRS result)
	* Makes reservation as a transaction, so all bookings will fail if any one booking fails
	*
	* @param username -- The agent making the booking
    *******************************************************************************************/
	public void addTripBookings(String username) {
		System.out.println("----Add Reservation for a Sequence of Trips----");
		int passenger_id = getIntFromUser("For which passenger ID # would you like to book a reservation? --> ",
			1, Integer.MAX_VALUE);
		int num_tickets = getIntFromUser("How many tickets would you like to reserve? --> : ", 1, Integer.MAX_VALUE);

		List<String> inserts = getTripInserts(passenger_id, num_tickets, username);

		try {
			conn.setAutoCommit(false);
			for(String insert : inserts) {
				Statement st = conn.createStatement();
				st.execute(insert);			
			}
			conn.setAutoCommit(true);
			if(inserts.isEmpty()) {
				System.out.println( "Canceled insert because you did not enter any trips." );
			}
			else {
				System.out.println( String.format("Reserved %d tickets for passenger %d",
					num_tickets, passenger_id) );
			}
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/* Helper method gets the trip SQL insert statements the agent wants to book */
	private List<String> getTripInserts(int passenger_id, int num_tickets, String agent_name) {
		List<String> result = new ArrayList<String>();
		int nextTrip = -1;
		do {
			nextTrip = getIntFromUser("Enter next trip ID # to book (or -1 if finished adding trips) --> ",
				-1, Integer.MAX_VALUE);
			if(nextTrip > 0) {
				String nextSQLStatement = String.format("INSERT INTO BOOKING VALUES(" +
					"'%s', %d, %d, %d);", agent_name, passenger_id, nextTrip, num_tickets);
				result.add(nextSQLStatement);
			}
		} while (nextTrip > 0);
		return result;
	}


	/********************************************************************
	* Find all trains that pass through a specific station at a specific
	* day/time combination: Find the trains that pass through a specific
	* station on a specific day and time.
	********************************************************************/
	public void trainsThruStation() {
		System.out.println("----Find trains which pass through a specific station at a given time----");

		int target_station = getIntFromUser("Enter the station's ID #: ", 1, Integer.MAX_VALUE);
		int target_day = getIntFromUser("Enter the travel day: ", 1, 7);
		int hour = getIntFromUser("Enter the travel hour: ", 0, 23);
		int minute = getIntFromUser("Enter the travel minute: ", 0, 59);

		String target_time = String.format("%02d:%02d:00", hour, minute);

		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM trains_through_this_station('%s', %d, %d);",
				target_time, target_day, target_station);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/* Find the routes that travel more than one rail line */
	public void moreThanOneRail() {
		System.out.println("----Find routes which travel more than one rail line----");
		try {
			Statement st = conn.createStatement();
			String query = "SELECT * FROM more_than_one_rail()";
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/********************************************************************************
	* Find routes that pass through the same stations but don’t have the same stops:
	* Find seemingly similar routes that differ by at least 1 stop.
	********************************************************************************/
	public void sameStationsDiffStops() {
		System.out.println("----Find routes which pass through the same stations but have different stops----");
		try {
			Statement st = conn.createStatement();
			String query = "SELECT * FROM same_stations_diff_stops()";
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/********************************************************************************
	* Find any stations that all the trains (that are in the system) pass at any
	* time during an entire week.
	********************************************************************************/
	public void stationsAllTrainsPassThrough() {
		System.out.println("----Find stations that all trains pass through----");
		try {	
			Statement st = conn.createStatement();
			String query = "SELECT * FROM stations_all_trains_pass_through()";
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/********************************************************************************
	* Find all trains that do not stop at a specified station at any
	* time during an entire week.
	********************************************************************************/
	public void trainsWhichDontGoHere() {
		System.out.println("----Find all trains that do not stop at a specific station----");

		int target_station = getIntFromUser("Enter the station's ID #: ", 1, Integer.MAX_VALUE);
		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM trains_which_dont_go_here(%d)", target_station);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}

	/********************************************************************************
	* Find routes that stop at least at XX% of the Stations they visit:
	* target_percent must be specified as a percentage between 10 and 90
	********************************************************************************/
	public void greaterThanPercentStops() {
		System.out.println("----Find routes that stop at at least a specified percentage of stations----");

		int target_percent = getIntFromUser("Enter the percentage as an integer (10 through 90): ", 10, 90);
		try {	
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM greater_than_percent_stops(%d)", target_percent);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/* Display all schedules of a specified route for the week */
	public void getRouteSchedule() {
		System.out.println("----Display the schedule of a route----");

		int target_route = getIntFromUser("Enter the route's ID #: ", 1, Integer.MAX_VALUE);
		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM get_route_schedule(%d)", target_route);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/*************************************************************************************** 
	* Find the availability of a route at every stop on a specific day and time
	* Will only return trips which stop either at the depart or destination stations
	***************************************************************************************/
	public void findRouteAvailability() {
		System.out.println("----Find the availability of a route at every stop on a specific day----");

		int target_route = getIntFromUser("Enter the route's ID #: ", 1, Integer.MAX_VALUE);
		int target_day = getIntFromUser("Enter the travel day: ", 1, 7);
		int hour = getIntFromUser("Enter the travel hour: ", 0, 23);
		int minute = getIntFromUser("Enter the travel minute: ", 0, 59);

		String target_time = String.format("%02d:%02d:00", hour, minute);
		try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT * FROM find_route_availability(%d, %d, '%s')", 
				target_route, target_day, target_time);
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}


	/* 
	* Drops all data from all tables, but retains the database schema 
	* Demands confirmation from the user before proceeding
	*/
	public void dropDatabase() {
		System.out.println("----Delete Database----");

		boolean confirmation = getBooleanFromUser("Are you sure you want to delete all the database information?\n" +
			"It is likely that this action is unrecoverable. Continue anyway (Y/N)? --> ");

		if(confirmation) {
			try {
			Statement st = conn.createStatement();
			String query = String.format("SELECT drop_database();");
			st.executeQuery(query);
			System.out.println("All database records have been deleted.");
			}
			catch (SQLException e) {
				handleSQLException(e);
			}
		}
		else {
			System.out.println("Aborted database deletion.");
		}
	}


	/* 
	* Provides options to import small test, large test, or custom datasets
	* WARNING -- this function allows the execution of arbitrary SQL code on the database!
	*/
	public void importDatabase() {
		System.out.println("----Import Database----");
		String importOptions = 	"1. Import small test dataset\n" +
								"2. Import large test dataset\n" +
								"3. Import custom dataset\n";

		String filename = null;
		String input = null;
		while(filename == null) {

			System.out.println(importOptions);
			System.out.print("Enter your choice: ");
			input = scan.nextLine();

			switch(input) {
				case "1":
					filename = "sql/small.sql";
					break;
				case "2":
					filename = "sql/mock_data.sql";
					break;
				case "3":
					filename = getStringFromUser("Enter the name of the file you would like to import: ");
					break;
				default:
					System.out.println("Invalid option selected.");
					continue;
			}
		}

		System.out.println(String.format("You have selected filename: %s", filename) );

		try {
			conn.setAutoCommit(false);
			FileReader dataReader = new FileReader(filename);
			System.out.println("Importing the file data...");
			runner.runScript(dataReader);

			//need to fix serials (ID#s) so they don't collide with the newly imported data
			if(input.equals("3")) {
				System.out.println("Updating database SERIAL IDs...");
				Statement s = conn.createStatement();
				String query = String.format("SELECT fix_serials();");
				s.execute(query);
			}

			conn.setAutoCommit(true);
			System.out.println(String.format("%s has been imported successfully.", filename));
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
		catch (IOException e2) {
			System.out.println("There was a problem executing your import script");
		}
	}


	/*********************************************************************************
	* Export all data stored in database into a user-specified filepath
	* Will export as the series of statements needed to reinstantiate that data
	*
	* not the most efficient storage, but should make it easier to import/export
	*********************************************************************************/
	public void exportDatabase() {
		System.out.println("----Export Database----");
		String filename = getStringFromUser("Enter the name of the file you would like to export to (will be appended with .sql): ");
		FileWriter outputFile = null;
		try {
			File fileObj = new File(filename + ".sql");
			if(!fileObj.exists())
				fileObj.createNewFile();
			else
				throw new FileNotFoundException();
			outputFile = new FileWriter (fileObj, true);
		}
		catch (IOException e2) {
			System.out.println("There was a problem writing to the specified filepath.");
			return;
		}

		try {
			for (String tableName : tableNames) {
				Statement st = conn.createStatement();
				String query = String.format("SELECT * FROM %s;", tableName);
				ResultSet result = st.executeQuery(query);
				appendResultSetToFile(tableName, result, outputFile);
				st.close();
			}
			System.out.println(String.format("The dataset has been exported to %s.sql successfully.", filename));
			outputFile.close();
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
		catch (IOException e2) {
			System.out.println("There was a problem exporting the database.");
		}

	}


	/* Helper method which appends insert statements for a given table/ResultSet to the filewriter */
	private static void appendResultSetToFile(String tableName, ResultSet rs, FileWriter fw) 
		throws IOException, SQLException {
		//skip tables with empty results
		if (!rs.isBeforeFirst() ) {
   			return;
		}

		fw.write("SELECT set_triggers(false);\n");

		ResultSetMetaData rsmd = rs.getMetaData();
		int numberOfColumns = rsmd.getColumnCount();
		
		while(rs.next()) {
			String line = String.format("INSERT INTO %s VALUES(", tableName);

			for(int i = 1; i <= numberOfColumns; i++) {
				int dataType = rsmd.getColumnType(i);

				String s = rs.getString(i);
				if(dataType == Types.INTEGER || dataType == Types.NUMERIC)
					line += s;
				else
					line += "'" + s + "'";
				if(i != numberOfColumns)
					line += ",";
			}
			line += ");\n";

			fw.write(line);
		}
		fw.write("SELECT set_triggers(true);\n\n");
	}


	/* Prints relevant details regarding SQLExceptions */
	private static void handleSQLException(SQLException ex) {
		while (ex != null) {
			System.out.println("Message = " + ex.getMessage());
			System.out.println("SQLState = "+ ex.getSQLState());
			System.out.println("Error Code = "+ ex.getErrorCode());
			ex = ex.getNextException();
		}
	}


	/* Format query results appropriately for the user */
	public void printResultSet(ResultSet rs) throws SQLException
	{
	    if (!rs.isBeforeFirst() ) {    
   			System.out.println("Your request returned no results."); 
		} 
		else {
			boolean continueDisplayingResults;
			int result_no = 1;
			do {
				System.out.printf("----Showing (up to) %d results, beginning with result %d----\n", 
					PAGINATION_CONSTANT, result_no);
		    	System.out.println(FlipTableConverters.fromResultSet(rs, PAGINATION_CONSTANT));
		    	continueDisplayingResults = false;
			    if(!rs.isAfterLast()) {
			    	result_no += PAGINATION_CONSTANT;
			    	continueDisplayingResults = getBooleanFromUser(
			    		String.format("Would you like to see another %d results? (Y/N)  ", PAGINATION_CONSTANT));
			    } 
			} while (continueDisplayingResults);
		}
	}


	/* 
	* gets an int value from user between min and max, inclusive 
	* prompts until a valid response is entered
	*/
	private int getIntFromUser(String prompt, int min, int max) {
		int result;
		do {
		    System.out.print(prompt);
		    while (!scan.hasNextInt()) {
		        System.out.print("\n" + prompt);
		        scan.next();
		    }
		    result = scan.nextInt();
		} while (result < min || result > max);

		scan.nextLine();
		return result;
	}

	/* 
	* gets an String from user of exactly length # of characters
	* Need this to aquire, for example, valid ZIP and phone # 
	* prompts until a valid response is entered
	*/
	private String getNlengthString(String prompt, int length) {
		String result;
		do {
		    System.out.print(prompt);
		    result = scan.nextLine();
		} while (result.length() != length);
		return result;
	}

	/* 
	* gets a generic String from user
	*/
	private String getStringFromUser(String prompt) {
		String result;
		System.out.print(prompt);
		result = scan.nextLine();
		return result;
	}

	/* 
	* gets true/false value from the user 
	* maps inputs starting in 'Y' or 'y' to True and everything else to False
	*/
	private boolean getBooleanFromUser(String prompt) {
		System.out.print(prompt);
		String input = scan.nextLine();
		return input.startsWith("Y") || input.startsWith("y");
	}

}
