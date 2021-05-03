/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.camel.kamelets.utils.transform;

import java.util.HashMap;
import java.util.Map;

import org.apache.camel.Exchange;
import org.apache.camel.ExchangeProperty;
import org.apache.camel.InvalidPayloadException;

public class InsertField {

    public Map<?, ?> process(@ExchangeProperty("field") String field, @ExchangeProperty("value") String value, Exchange ex) throws InvalidPayloadException {
        Map<Object, Object> body = ex.getMessage().getBody(Map.class);
        if (body == null) {
            String val = ex.getMessage().getMandatoryBody(String.class);
            body = new HashMap<>();
            // TODO: make this configurable
            body.put("content", val);
        }
        body.put(field, value);
        return body;
    }

}