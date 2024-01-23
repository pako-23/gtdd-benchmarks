package tests;

import static org.junit.Assert.assertEquals;
import static utils.Login.*;
import org.junit.After;
import org.junit.Test;
import org.junit.Before;
import po.LoggedHome;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class AddNewArticleTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaAddNewArticle() throws Exception {
		String title = "Test Article 00";
		String body = "This is the body of the first article for testing the platform";
		LoggedHome home = loginAsAdmin(driver)
				.createPost()
				.setTitle(title)
				.setBody(body)
				.save();

		assertEquals(title, home.getFirstArticleTitle());
		assertEquals(body, home.getFirstArticleBody());
		home.adminLogout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
