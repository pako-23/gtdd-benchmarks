package tests;


import static org.junit.Assert.assertEquals;
import static utils.Login.*;
import po.ProfilePageInfo;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class LoginAsAdminTest {

	private WebDriver driver;

    @Before
    public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaLoginAsAdmin() throws Exception {
		ProfilePageInfo profile = loginAsAdmin(driver);
		assertEquals("Super User", profile.getName());
		profile.adminLogout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}
}
