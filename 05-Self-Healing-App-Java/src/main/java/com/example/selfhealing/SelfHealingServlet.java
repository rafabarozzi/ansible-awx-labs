package com.example.selfhealing;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class SelfHealingServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");

        PrintWriter out = response.getWriter();

        out.println("<html>");
        out.println("<head>");
        out.println("<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">");
        out.println("<title>Plataforma Self-Healing</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Plataforma Self-Healing</h1>");
        out.println("<div class=\"sidebar\">");
        out.println("<h2>Self-Healing</h2>");
        out.println("<button id=\"registerBtn\">Cadastrar</button>");
        out.println("</div>");
        out.println("<div class=\"content\">");
        out.println("<h2>Cadastro</h2>");
        out.println("<form action=\"#\" method=\"post\">");
        out.println("Hostname: <input type=\"text\" name=\"hostname\"><br>");
        out.println("IP: <input type=\"text\" name=\"ip\"><br>");
        out.println("Ação: <input type=\"text\" name=\"action\"><br>");
        out.println("Serviço: <input type=\"text\" name=\"service\"><br>");
        out.println("<input type=\"submit\" value=\"Cadastrar\">");
        out.println("</form>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
}