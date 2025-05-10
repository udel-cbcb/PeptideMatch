package query; 

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class RunLongProcessServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
           LongProcess longProcess = (LongProcess) request.getSession().getAttribute("longProcess");
        if ("XMLHttpRequest".equals(request.getHeader("x-requested-with"))) {
            //response.setContentType("application/json");
            response.setContentType("text/html");
            //response.getWriter().write(String.valueOf(longProcess.getProgress()));
	    System.out.println("Get: "+longProcess.getStatus());
            response.getWriter().write(String.valueOf(longProcess.getStatus()));
        }
	else if(request.getParameter("getLog").equals("true")) {
            //LongProcess longProcess = (LongProcess) request.getSession().getAttribute("longProcess");
            longProcess = (LongProcess) request.getSession().getAttribute("longProcess");
	    if(longProcess != null) {
            response.setContentType("text/html");
            response.getWriter().write(String.valueOf(longProcess.getLog()));
	    }
	    else {
        	response.sendRedirect("startLongProcess.jsp");
	    }
	} 
	else {
            //request.getRequestDispatcher("runLongProcess.jsp").forward(request, response);
	    System.out.println("Get ShowProgress: "+longProcess.getStatus());
            request.getRequestDispatcher("showProgress.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        LongProcess longProcess = new LongProcess();
        longProcess.setDaemon(true);
        longProcess.start();
        request.getSession().setAttribute("longProcess", longProcess);
        //request.getRequestDispatcher("runLongProcess.jsp").forward(request, response);
	    System.out.println("Post ShowProgress: "+longProcess.getStatus());
        request.getRequestDispatcher("showProgress.jsp").forward(request, response);
    }

}

class LongProcess extends Thread {

    private int progress;
    private String status="";
    private String log = ""; 
    public void run() {
        while (progress < 100) {
            try { sleep(1000); } catch (InterruptedException ignore) {}
            progress++;
	    status ="Current status: "+progress+" %<br/>"+status;
	    log +="Current status: "+progress+" %<br/>";
        }
	status ="Finished <a href=runLongProcess?getLog=true>View Log</a>";
	log +="Finished";
    }

    public int getProgress() {
        return progress;
    }
  	
    public String getStatus() {
	return status;
    } 
    
    public String getLog() {
	return log;
    } 
}
