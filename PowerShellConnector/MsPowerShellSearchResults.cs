/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright (c) 2014-2016 ForgeRock AS. All Rights Reserved
 *
 * The contents of this file are subject to the terms
 * of the Common Development and Distribution License
 * (the License). You may not use this file except in
 * compliance with the License.
 *
 * You can obtain a copy of the License at
 * http://forgerock.org/license/CDDLv1.0.html
 * See the License for the specific language governing
 * permission and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL
 * Header Notice in each file and include the License file
 * at http://forgerock.org/license/CDDLv1.0.html
 * If applicable, add the following below the CDDL Header,
 * with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 */

using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Org.IdentityConnectors.Framework.Common;
using Org.IdentityConnectors.Framework.Common.Exceptions;
using Org.IdentityConnectors.Framework.Common.Objects;
using Org.IdentityConnectors.Framework.Spi;

namespace Org.ForgeRock.OpenICF.Connectors.MsPowerShell
{
    internal class MsPowerShellSearchResults
    {
        private readonly ObjectClass _objectClass;
        private readonly ResultsHandler _handler;

        public MsPowerShellSearchResults(ObjectClass objectClass, ResultsHandler handler)
        {
            _objectClass = objectClass;
            _handler = handler;
        }

        public void Complete()
        {
            ((SearchResultsHandler) _handler).HandleResult(new SearchResult(null, -1));
        }

        public void Complete(string searchResult)
        {
            string cookie = null;
            if (!string.IsNullOrEmpty(searchResult))
            {
                cookie = searchResult;
            }
            ((SearchResultsHandler) _handler).HandleResult(new SearchResult(cookie, -1));
        }

        public void Complete(SearchResult searchResult)
        {
            string cookie = null;
            int pages = -1;
            if (searchResult != null)
            {
                if (!string.IsNullOrEmpty(searchResult.PagedResultsCookie))
                {
                    cookie = searchResult.PagedResultsCookie;
                }
                pages = searchResult.RemainingPagedResults;
            }
            ((SearchResultsHandler) _handler).HandleResult(new SearchResult(cookie, pages));
        }

        public object Process(object result)
        {
            if (result == null)
            {
                return true;
            }

            if (result is ConnectorObject)
            {
                return _handler.Handle((ConnectorObject) result);
            }

            var cobld = new ConnectorObjectBuilder();
            var res = result as Hashtable;
            foreach (string key in res.Keys)
            {
                var attrName = key;
                var attrValue = res[key];
                if ("__UID__".Equals(attrName))
                {
                    if (attrValue == null)
                    {
                        throw new ConnectorException("Uid can not be null");
                    }
                    cobld.SetUid(attrValue.ToString());
                }
                else if ("__NAME__".Equals(attrName))
                {
                    if (attrValue == null)
                    {
                        throw new ConnectorException("Name can not be null");
                    }
                    cobld.SetName(attrValue.ToString());
                }
                else
                {
                    cobld.AddAttribute(FormatAndBuildAttribute(attrName, attrValue));
                }
            }
            cobld.ObjectClass = _objectClass;
            return _handler.Handle(cobld.Build());
        }

        internal static ConnectorAttribute FormatAndBuildAttribute(string name, object value)
        {
            if (value == null)
            {
                return ConnectorAttributeBuilder.Build(name);
            }
            else if (value is byte[])
                // byte[] is a specific type in ICF... 
                //we do not want to convert it to a multi valued attribute
            {
                return ConnectorAttributeBuilder.Build(name, value);
            }
            else if (value is Hashtable)
            // HashTable is a common PowerShell type.
            // It needs to be converted to IDictionary 
            // to be a supported ICF type
            {
                return ConnectorAttributeBuilder.Build(name, HashTableToIDictionary(value as Hashtable));
            }
            else if (value is IDictionary)
            {
                return ConnectorAttributeBuilder.Build(name, value);
            }
            else if (value is object[] || value is IList)
            {
                var list = new Collection<object>();
                foreach (var val in (ICollection) value)
                {
                    if (val == null) continue;
                    // HashTable is a common PowerShell type.
                    // It needs to be converted to IDictionary 
                    // to be a supported ICF type
                    if (val.GetType() == typeof(Hashtable))
                    {
                        list.Add(HashTableToIDictionary(val as Hashtable));
                    }
                    else
                    {
                        // Make sure we have a supported type or serialization will fail
                        // Default to String representation otherwise
                        list.Add(FrameworkUtil.IsSupportedAttributeType(val.GetType())
                            ? val
                            : val.ToString());
                    }
                }
                return ConnectorAttributeBuilder.Build(name, list);
            }
            else
            {
                return ConnectorAttributeBuilder.Build(name, FrameworkUtil.IsSupportedAttributeType(value.GetType())
                    ? value
                    : value.ToString());
            }
        }

        private static IDictionary<string, Object> HashTableToIDictionary(Hashtable hash)
        {
            IDictionary<string, object> dic = new Dictionary<string, object>();
            foreach (string key in hash.Keys)
            {
                if (hash[key] == null) continue;
                var value = FrameworkUtil.IsSupportedAttributeType(hash[key].GetType())
                    ? hash[key]
                    : hash[key].ToString();
                dic.Add(key, value);
            }
            return dic;
        }
    }
}