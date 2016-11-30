package com.rules.parser;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by rameez on 11/27/16.
 */
public class RulesParser {

    public ArrayList<Rule> Parse() {
        Scanner sc = new Scanner(RulesParser.class.getResourceAsStream("rules.txt"));
        sc.nextLine();
        sc.nextLine();
        ArrayList<Rule> Rules = new ArrayList<>();
        while (sc.hasNextLine()) {
            Rule rule = new Rule();
            String line = sc.nextLine().replaceAll("\\s+", " ");
            double support = Double.valueOf(line.split(" ")[4].replaceAll("\"",""));
            float confidence = Float.parseFloat(line.split(" ")[5]);
            double lift = Double.valueOf(line.split(" ")[6].replaceAll("\"",""));
            rule.support = support;
            rule.confidence = confidence;
            rule.lift = lift;
            Matcher matcher = Pattern.compile("\\{([^}]+)\\}").matcher(sc.nextLine());
            while (matcher.find())
            {
                if (matcher.group(1).contains("android.")) {
                    rule.right_hand_side = matcher.group(1);
                } else {
                    rule.left_hand_side = matcher.group(1);
                }
            }
            Rules.add(rule);
        }
        return Rules;

    }

    public ArrayList<Rule> getRuleForClass(ArrayList<Rule> rules, String class_name){
        ArrayList<Rule> temp = new ArrayList<>();
        for(int i =0; i<rules.size(); i++)
        {
            if(rules.get(i).left_hand_side == null || rules.get(i).right_hand_side == null )
            {
                continue;
            }
            if(rules.get(i).left_hand_side.equals(class_name))
            {
                temp.add(rules.get(i));
            }
        }
        return temp;
    }
}
