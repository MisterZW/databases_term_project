import java.util.Properties;
import java.sql.*;
public class JavaDemo {
	public static void main(String args[]) throws SQLException, ClassNotFoundException{

		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://localhost/zdw9";

		Properties props = new Properties();
		props.setProperty("user","zdw9");
		props.setProperty("password","example");

		Connection conn = DriverManager.getConnection(url, props);
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
	}
}
