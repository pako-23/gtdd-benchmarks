package tests;

import static org.junit.Assert.assertEquals;
import static utils.Login.*;
import po.LoggedHome;
import org.junit.Before;
import org.junit.After;
import org.junit.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class EditArticleTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaEditArticle() throws Exception {
		String expectedBody = "This is the body of the first article for testing the platformEDITED0";

		LoggedHome home = loginAsAdmin(driver)
				.home();

		home.editIthArticle(1)
				.setBody("EDITED0")
				.save();
		assertEquals(expectedBody, home.getIthArticleBody(1));
		home.adminLogout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
