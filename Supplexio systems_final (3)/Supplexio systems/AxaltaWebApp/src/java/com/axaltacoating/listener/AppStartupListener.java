package com.axaltacoating.listener;

import java.util.TimeZone;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Application startup listener that configures global JVM settings.
 *
 * <p>Sets the default JVM timezone to IST (Asia/Kolkata) so that:
 * <ul>
 *   <li>All {@code <fmt:formatDate>} tags in JSPs display times in IST</li>
 *   <li>All {@code SimpleDateFormat} instances without an explicit timezone parse/format in IST</li>
 *   <li>Auction status comparisons using {@code new Date()} work correctly in IST</li>
 * </ul>
 * This prevents auctions from appearing as "SCHEDULED" when the server is hosted in UTC.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Set JVM default timezone to Indian Standard Time
        TimeZone ist = TimeZone.getTimeZone("Asia/Kolkata");
        TimeZone.setDefault(ist);
        sce.getServletContext().log(
            "AppStartupListener: JVM default timezone set to " + ist.getID()
        );
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Nothing to clean up
    }
}
