package runner;

import com.intuit.karate.Results;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class Runner {

    @Test
    void testParallel() {
        Results results = com.intuit.karate.Runner.path("classpath:features")
                .reportDir("target/karate-reports")
                .outputCucumberJson(true)
                .parallel(1);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
