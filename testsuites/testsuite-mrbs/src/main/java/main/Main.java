package main;

import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.junit.runner.notification.Failure;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runners.Suite.SuiteClasses;

public class Main {

    private static List<String> getTestSuite() {
        SuiteClasses ann = TestSuite.class.getAnnotation(SuiteClasses.class);
        return Arrays.stream(ann.value())
            .map(c -> c.getName())
            .collect(Collectors.toList());
    }

    private static Class<?>[] getTests(final String[] args) {
        final List<String> testNames =
            args.length == 0 ? getTestSuite() : Arrays.asList(args);

        final Class<?>[] tests = new Class<?>[testNames.size()];

        try {
            for (int i = 0; i < tests.length; ++i)
                tests[i] = Class.forName(testNames.get(i));
        } catch(ClassNotFoundException ex) {
            System.err.println(ex.toString());
            System.exit(1);
        }

        return tests;
    }

    public static void main(final String[] args) {
        if (args.length > 0 && Arrays.asList(args).contains("--list-tests")) {
            getTestSuite().forEach(System.out::println);
            System.exit(0);
        }

        final Class<?>[] tests = getTests(args);
        final Result result = JUnitCore.runClasses(tests);

        for (final Failure f : result.getFailures()) System.out.println(f);

        final Set<String> failures = result.getFailures().stream()
            .map(r -> r.getDescription().getClassName())
            .collect(Collectors.toSet());

        for (final Class<?> test : tests) {
            final String testName = test.getName();
            final int failed = failures.contains(testName) ? 0 : 1;
            System.out.println(String.format("%s %d", testName, failed));
        }

        System.exit(0);
    }
}
