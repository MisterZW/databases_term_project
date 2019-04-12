package src;

import java.util.*;
import java.sql.*;
import java.sql.SQLException;

public class ExpressRailway {

	public final static int ZIP_LENGTH = 5;
	public final static int PHONE_NUMBER_LENGTH = 10;

	private Connection conn;
	private Properties props;
	public static Scanner scan;

	public ExpressRailway() throws SQLException, ClassNotFoundException {
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://localhost/zdw9";

		props = new Properties();
		props.setProperty("user","zdw9");
		props.setProperty("password","example");

		conn = DriverManager.getConnection(url, props);

		UIMenu();
	}

	public void UIMenu(){
		scan = new Scanner(System.in);
		String start = "--------Welcome to Express Railway---------\n\n"
							+ "\t1. Log In";
		
		String menu = "--------Welcome to Express Railway---------\n\n"
							+ "\t1. Add a new customer account\n"
							+ "\t2. Edit a a customer account\n"
							+ "\t3. View customer account information\n"
							+ "\t4. Single Route Trip Search\n"
							+ "\t5. Combination Route Trip Search\n"
							+ "\t6. Add Reservation\n"
							+ "\t7. Find trains which pass through a specific station at a given time\n"
							+ "\t8. Find trains with more than one rail line\n"
							+ "\t9. Find routes with more than one line\n"
							+ "\t10. Find stations that all trains pass through\n"
							+ "\t11. Find all trains that does not stop at a specific station\n"
							+ "\t12. Find routes that stop at a certain percent of stations\n"
							+ "\t13. Display the schedule of a route\n"
							+ "\t14. Find the availability of a route at every stop on a specific day\n"
							+ "\t15. Import Database\n"
							+ "\t16. Export Database\n"
							+ "\t17. Delete Database\n"
							+ "\t18. Exit\n";
		
		while(true) {
			System.out.println(menu);
			System.out.print("Enter your choice: ");
			String input = scan.nextLine();
			
			switch(input) {
			case "1":
				addNewCustomer();
				break;
			case "2":
				break;
			case "3":
				viewCustomer();
				break;
			case "4":
				singleTripRouteSearch();
				break;
			case "5":
				break;
			case "6":
				break;
			case "7":
				trainsThruStation();
				break;
			case "8":
				break;
			case "9":
				break;
			case "10":
				break;
			case "11":
				break;
			case "12":
				break;
			case "13":
				break;
			case "14":
				break;
			case "15":
				
			case "16":
				break;
			case "17":
				break;
			case "18":
				scan.close();
				System.exit(0);
				break;
			default:
				continue;
			}
			confirmContinue();
		}
		
	}

	public static void main(String args[]) throws SQLException, ClassNotFoundException {
		new ExpressRailway();
	}

	/* Confirm user wants to continue operations to avoid spamming menu after displaying results */
	public void confirmContinue() {
		System.out.println("--- Press enter to return to the menu ---");
		scan.nextLine();
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
	* Insert a new customer in to the system
	# Prints the new customer ID if successful
	*/
	public boolean addNewCustomer() {
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
	* View customer data associated with a given customer's ID # in the database
	*/
	public void viewCustomer() {
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

		try {
			Statement st = conn.createStatement();
			String query = "SELECT * FROM single_trip_route_search(" + arrival_station + ", " + 
			destination_station + ", " + target_day + ");";
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
	}

	/********************************************************************
	* Find all trains that pass through a specific station at a specific
	* day/time combination: Find the trains that pass through a specific
	* station on a specific day and time.
	********************************************************************/
	public void trainsThruStation() {
		System.out.println("Find trains which pass through a specific station at a given time");

		int target_station = getIntFromUser("Enter the station's ID #: ", 1, Integer.MAX_VALUE);
		int target_day = getIntFromUser("Enter the travel day: ", 1, 7);
		int hour = getIntFromUser("Enter the travel hour: ", 0, 23);
		int minute = getIntFromUser("Enter the travel minute: ", 0, 59);

		String target_time = String.format("%02d:%02d:00", hour, minute);

		try {
			Statement st = conn.createStatement();
			String query = "SELECT * FROM trains_through_this_station('" +
			target_time + "', " + target_day + ", " + target_station + ");";
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
		}
		catch (SQLException e) {
			handleSQLException(e);
		}
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
	final public static void printResultSet(ResultSet rs) throws SQLException
	{
	    if (!rs.isBeforeFirst() ) {    
   			System.out.println("Your request returned no results."); 
		} 
		else {
		    System.out.println(FlipTableConverters.fromResultSet(rs));
		}
	}
}

/*
	Statement st = conn.createStatement();
	String query1 = "SELECT * FROM TRAIN";
	ResultSet res1 = st.executeQuery(query1);

	int train_id, top_speed, seats; 
	double ppm;

	while (res1.next()) {
		train_id = res1.getInt("train_id");
		top_speed = res1.getInt("top_speed");
		seats = res1.getInt("seats");
		ppm = res1.getDouble("ppm");
		System.out.println("Train ID: " + train_id + " Top Speed: " + top_speed + " Seats: " + seats + " PPM " + ppm);
	}
*/
