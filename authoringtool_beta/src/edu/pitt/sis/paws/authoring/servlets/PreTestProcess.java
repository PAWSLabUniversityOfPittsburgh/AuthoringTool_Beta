package edu.pitt.sis.paws.authoring.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet implementation class PreTestProcess
 */
public class PreTestProcess extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PreTestProcess() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HashMap<String,String> stringInput = new HashMap<String,String>();
		stringInput.put("q_1_", "3");
		stringInput.put("q_2_", "10");
		stringInput.put("q_3_1", "30.0"); stringInput.put("q_3_2", "30.0"); stringInput.put("q_3_3", ""); stringInput.put("q_3_4", "");
		stringInput.put("q_4_1", "3"); stringInput.put("q_4_2", "4"); stringInput.put("q_4_3", "15"); stringInput.put("q_4_4", "");
		stringInput.put("q_5_1", "5"); stringInput.put("q_5_2", ""); stringInput.put("q_5_3", ""); stringInput.put("q_5_4", "");
		stringInput.put("q_6_1", "2.2"); stringInput.put("q_6_2", "3.3"); stringInput.put("q_6_3", ""); stringInput.put("q_6_4", "");
		stringInput.put("q_7_1", "false"); stringInput.put("q_7_2", ""); stringInput.put("q_7_3", ""); stringInput.put("q_7_4", "");
		stringInput.put("q_8_1", "Blue"); stringInput.put("q_8_2", "40.0"); stringInput.put("q_8_3", "30.0"); stringInput.put("q_8_4", "");
		stringInput.put("q_9_3", "c"); stringInput.put("q_9_6", "f"); stringInput.put("q_9_7", "g");
		stringInput.put("q_10_1", "Not equal"); stringInput.put("q_10_2", ""); stringInput.put("q_10_3", ""); stringInput.put("q_10_4", "");
		
		HashMap<String,Boolean> questions = new HashMap<String,Boolean>();
		for (Integer i=1; i<=10; i++) {
			questions.put(i.toString(), true);
		}
		
		String json = request.getParameter("arrayData");
		if (json != null) {
			try {
				JSONObject obj = new JSONObject(json);
				JSONArray array = obj.getJSONArray("inputs");
				for(int i = 0 ; i < array.length() ; i++){
					String key = array.getJSONObject(i).getString("key");
					if (stringInput.containsKey(key)) {
						String val = array.getJSONObject(i).getString("value");
						if (!stringInput.get(key).equalsIgnoreCase(val)) {
							String qKey = key.substring(2, key.lastIndexOf("_"));
							if (questions.containsKey(qKey)) {
								questions.put(qKey, false);
							}
						}
					} else {
						String qKey = key.substring(2, key.lastIndexOf("_"));
						if (questions.containsKey(qKey)) {
							questions.put(qKey, false);
						}
					}
				}
				
				String jsonResponse = "[";
				boolean first = true;
				for (String key: questions.keySet()) {
					if (first) {
						jsonResponse += "{\"key\" : \""+key+"\", \"value\" : \""+questions.get(key)+"\"}";
					} else {
						jsonResponse += ",{\"key\" : \""+key+"\", \"value\" : \""+questions.get(key)+"\"}";
					}
					first = false;
				}
				jsonResponse += "]";
				PrintWriter out = response.getWriter();
				out.println(jsonResponse);
			} catch (Exception e) {
				System.out.println(e);
				response.sendError(HttpServletResponse.SC_NOT_FOUND);
			}
		} else {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
		}
	}

}