import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.logging.Logger;

public class Example_7
{
  private static final String PEPTIDEMATCH_SERVER = "http://alanine.bioinformatics.udel.edu/peptidematch_new/webservices/peptidematch_rest";
  private static final Logger LOG = Logger.getAnonymousLogger();

  private static void run(ParameterNameValue[] params)
    throws Exception
  {
    StringBuilder locationBuilder = new StringBuilder(PEPTIDEMATCH_SERVER + "?");
    for (int i = 0; i < params.length; i++)
    {
      if (i > 0)
        locationBuilder.append('&');
      locationBuilder.append(params[i].name).append('=').append(params[i].value);
    }
    String location = locationBuilder.toString();
    URL url = new URL(location);
    LOG.info("Submitting...");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    HttpURLConnection.setFollowRedirects(true);
    conn.setDoInput(true);
    conn.connect();

    int status = conn.getResponseCode();
    while (true)
    {
      int wait = 0;
      String header = conn.getHeaderField("Retry-After");
      if (header != null)
        wait = Integer.valueOf(header);
      if (wait == 0)
        break;
      LOG.info("Waiting (" + wait + ")...");
      conn.disconnect();
      Thread.sleep(wait * 1000);
      conn = (HttpURLConnection) new URL(location).openConnection();
      conn.setDoInput(true);
      conn.connect();
      status = conn.getResponseCode();
    }
    if (status == HttpURLConnection.HTTP_OK)
    {
      LOG.info("Got a OK reply");
      InputStream reader = conn.getInputStream();
      URLConnection.guessContentTypeFromStream(reader);
      StringBuilder builder = new StringBuilder();
      int a = 0;
      while ((a = reader.read()) != -1)
      {
        builder.append((char) a);
      }
      System.out.println(builder.toString());
    }
    else
      LOG.severe("Failed, got " + conn.getResponseMessage() + " for "
        + location);
    conn.disconnect();
  }

  public static void main(String[] args)
    throws Exception
  {
	int i = 0;
	String arg = null;
	String queryFile = "";
	String organismFile = "";
	String query = "";
	String organism = "";
	String format = "tab";
	while(args.length > i && args[i].startsWith("-")) {
		arg = args[i++];
		if(arg.equals("-queryFile")) {
			if(args.length > i) {
				queryFile = args[i++];
				query = readFileContent(queryFile);
			} 
			else {
				System.err.println("-queryFile requires a filename");
			}
		}
		else if(arg.equals("-organismFile")) {
			if(args.length > i) {
				organismFile = args[i++];
				organism = readFileContent(organismFile);
			} 
			else {
				System.err.println("-organismFile requires a filename");
			}
		}
		else if(arg.equals("-format")) {
			if(args.length > i) {
				format = args[i++];
			} 
			else {
				System.err.println("-format requires a value");
			}
		}

	}
	if(args.length < 2) {
		System.err.println("Usage: Example_7 [-queryFile] queryFileName [-organismFile] organismFileName [-format] tab|xls|fasta|xml");
		System.exit(1);
	}
    run(new ParameterNameValue[] {
      new ParameterNameValue("format", format),
      new ParameterNameValue("query", query),
      new ParameterNameValue("organism", organism),
    });
  }
  private static String readFileContent(String fileName) { 
	String fileContent = "";
	try {
		FileReader input = new FileReader(fileName);
		BufferedReader bufRead = new BufferedReader(input);
		String line;
		line = bufRead.readLine();
		while(line != null) {
			fileContent += line+",";
			line = bufRead.readLine();
		}
		bufRead.close();
	}catch(IOException ioe) {
		ioe.printStackTrace();
	}
	fileContent = fileContent.substring(0, fileContent.length() -1);
	return fileContent;
  }

  private static class ParameterNameValue
  {
    private final String name;
    private final String value;

    public ParameterNameValue(String name, String value)
      throws UnsupportedEncodingException
    {
      this.name = URLEncoder.encode(name, "UTF-8");
      this.value = URLEncoder.encode(value, "UTF-8");
    }
  }
}
