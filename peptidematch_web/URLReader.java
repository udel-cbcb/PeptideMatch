import java.net.*;
import java.io.*;

public class URLReader {
    public static void main(String[] args) throws Exception {

        URL oracle = new URL("https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/Search?search_key=AAVEEGIVLGGGCALLR&apply_action=GO&exact_match=exact_match");
        BufferedReader in = new BufferedReader(
        new InputStreamReader(oracle.openStream()));

        String inputLine;
        while ((inputLine = in.readLine()) != null)
            System.out.println(inputLine);
        in.close();
    }
}
