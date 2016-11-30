/*
 * Copyright 2000-2016 JetBrains s.r.o.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package myPlugin.src;

import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.PlatformDataKeys;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.Messages;
import com.rules.parser.Rule;
import com.rules.parser.RulesParser;

import java.util.ArrayList;

/**
 * Created by rameez on 11/27/16.
 */
public class TextBoxes extends AnAction {
  RulesParser parser;
  ArrayList<Rule> rules;
  ArrayList<Rule> rulesForClass;
  public TextBoxes() {
    // Set the menu item name.
    super("Recommend _Intent Action");
    // Set the menu item name, description and icon.
    // super("Text _Boxs","Item description",IconLoader.getIcon("/Mypackage/icon.png"));
    parser = new RulesParser();
    rules = parser.Parse();
  }

  public void actionPerformed(AnActionEvent event) {
    Project project = event.getData(PlatformDataKeys.PROJECT);
    String txt= Messages.showInputDialog(project, "Android Class Name", "Android Class Name", Messages.getQuestionIcon());
    String recommendation="";
    rulesForClass = parser.getRuleForClass(rules,txt);
    int i=1;
    for(Rule rule : rulesForClass){
      recommendation+=i+") "+rule.right_hand_side+"\t Confidece: "+rule.confidence+"\n\n";
      i++;
    }
    Messages.showMessageDialog(project, recommendation, "Recommended Intent Actions", Messages.getInformationIcon());
  }

}
