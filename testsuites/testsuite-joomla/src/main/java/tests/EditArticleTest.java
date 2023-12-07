package tests;

import static org.testng.AssertJUnit.assertEquals;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.LoggedHome;
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
		int article = 1;

		String expectedBody = "This is the body of the first article for testing the platformEDITED0";

		LoggedHome home = loginAsAdmin(driver).home();

		home.editIthArticle(article).setBody("EDITED0").save();
		assertEquals(expectedBody, home.getIthArticleBody(article));
		home.adminLogout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
