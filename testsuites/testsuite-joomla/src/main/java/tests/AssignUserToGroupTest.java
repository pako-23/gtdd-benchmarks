package tests;

import static org.junit.Assert.assertTrue;
import static utils.Login.*;
import po.ManageUsersPage;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class AssignUserToGroupTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaAsignUserToGroup() throws Exception {
		String group = "Test Group 000";
		String user = "Test User00";
		ManageUsersPage users = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.users()
				.editUser(user)
				.assignedGroups()
				.checkGroup(10)
				.saveAndClose();

		assertTrue(users.containsGroup(2, group));
		users.logout();

	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}
}
