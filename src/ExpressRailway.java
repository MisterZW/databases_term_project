import java.util.*;
import java.sql.*;
import java.sql.SQLException;
//import com.jakewharton.fliptables.FlipTableConverters;

public class ExpressRailway {

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

		//begin the UI menu
		singleTripRouteSearch(1, 20, 3);

	}

	public static void UIMenu(){
		scan = new Scanner(System.in);
		String start = "--------Welcome to Express Railway---------"
							+ "			Login Menu		"
							+ "\t1. Log In";
		
		String menu = "--------Welcome to Express Railway---------"
							+ "			Main Menu		"
							+ "\t1. Single Route Trip Search"
							+ "\t2. Combination Route Trip Search"
							+ "\t3. Add Reservation"
							+ "\t4. Find Specific Train"
							+ "\t5. Find train with more than one rail line"
							+ "\t6. Find routes with more than one line"
							+ "\t7. Find stations that all trains pass through"
							+ "\t8. Find all trains that does not stop at a specific station"
							+ "\t9. Find routes that stop at a certain percent of stations"
							+ "t\10. Display the schedule of a route"
							+ "t\11. Find the availability of a route at every stop on a specific day"
							+ "\t12. Import Database"
							+ "t\13. Export Database"
							+ "t\14. Delete Database"
							+ "t\15. Exit";
		
		while(true) {
			System.out.println(menu);
			System.out.print("Enter your choice: ");
			String input = scan.next();
			
			switch(input) {
			case "1":
				break;
			case "2":
				break;
			case "3":
				break;
			case "4":
				break;
			case "5":
				break;
			case "6":
				break;
			case "7":
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
				System.exit(0);
				break;
			default:
				break;	
				
			}
		}
		
	}

	public static void main(String args[]) throws SQLException, ClassNotFoundException {
		new ExpressRailway();
	}

	public void singleTripRouteSearch(int arrival_station, int destination_station, int target_day) {
	
		try {
			Statement st = conn.createStatement();
			String query = "SELECT * FROM single_trip_route_search(" + arrival_station + ", " + 
			destination_station + ", " + target_day + ");";
			ResultSet rs = st.executeQuery(query);
			printResultSet(rs);
			//System.out.println(FlipTableConverters.fromResultSet(rs));
		}
		catch (SQLException e) {
			handleSQLException(e);
		}

	}

	public void handleSQLException(SQLException ex) {
		while (ex != null) {
			System.out.println("Message = " + ex.getMessage());
			System.out.println("SQLState = "+ ex.getSQLState());
			System.out.println("Error Code = "+ ex.getErrorCode());
			ex = ex.getNextException();
		}
	}

	final public static void printResultSet(ResultSet rs) throws SQLException
	{
    ResultSetMetaData rsmd = rs.getMetaData();
    int columnsNumber = rsmd.getColumnCount();
    while (rs.next()) {

    	for (int i = 1; i <= columnsNumber; i++) {
			if (i > 1) System.out.print(" | ");
			System.out.print(rsmd.getColumnName(i));
		}

		System.out.println();

        for (int i = 1; i <= columnsNumber; i++) {
            if (i > 1) System.out.print(" | ");
            System.out.print(rs.getString(i));
        }
        System.out.println();
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
